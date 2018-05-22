#!/bin/bash
set -euox pipefail
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start Consul
CONSUL_DOCKER_NAME=charts-consul
CONSUL_PORT=8500
export CONSUL_HTTP_ADDR="127.0.0.1:${CONSUL_PORT}"
CONSUL_VERSION=0.9.2
CONSUL_SCHEME=http

docker stop $CONSUL_DOCKER_NAME 2>/dev/null || true
docker run --rm -d --name $CONSUL_DOCKER_NAME -p 127.0.0.1:${CONSUL_PORT}:$CONSUL_PORT \
    consul:${CONSUL_VERSION}

CNT=0
while ! curl -sI "$CONSUL_SCHEME://$CONSUL_HTTP_ADDR/v1/status/leader" > /dev/null; do
	sleep 0.1
	CNT=$(expr $CNT + 1)
	if [ $CNT -gt 20 ]
	then
		docker logs $CONSUL_DOCKER_NAME
		exit 1
	fi
done

# Start Vault
VAULT_DOCKER_NAME=charts-vault
VAULT_PORT=8200
export VAULT_ADDR="http://127.0.0.1:${VAULT_PORT}"
VAULT_VERSION=0.8.3
VAULT_ROOT_TOKEN=vault-root-token
docker stop $VAULT_DOCKER_NAME 2>/dev/null || true
docker run --rm --name $VAULT_DOCKER_NAME -d -e SKIP_SETCAP=1 -p 127.0.0.1:${VAULT_PORT}:$VAULT_PORT vault:${VAULT_VERSION} server -dev -dev-root-token-id $VAULT_ROOT_TOKEN

CNT=0
while ! curl -sI "$VAULT_ADDR/v1/sys/health" > /dev/null; do
	sleep 0.1
	CNT=$(expr $CNT + 1)
	if [ $CNT -gt 20 ]
	then
		docker logs $VAULT_DOCKER_NAME
		exit 1
	fi
done

# Start Kubernetes if minikube status is Stopped
if minikube status --format "{{.MinikubeStatus}}" | grep -i stopped > /dev/null
then
	minikube start
fi

vault auth $VAULT_ROOT_TOKEN
vault auth-enable kubernetes
vault write auth/kubernetes/config \
    kubernetes_host=https://192.168.99.100:8443 \
    kubernetes_ca_cert=@$HOME/.minikube/ca.crt



for policy_dir in $(ls $DIR/kubernetes-vault-policies); do
	# Create the Vault policy for this role
    vault policy-write $policy_dir $DIR/kubernetes-vault-policies/$policy_dir/policy.hcl
    # Create a Namespace and ServiceAcccount for this application
    kubectl create namespace $policy_dir || true
    kubectl -n $policy_dir create serviceaccount $policy_dir || true 

    # Create Auth Delegator and Secret management role bindings for Vault auth
    kubectl create clusterrolebinding $policy_dir-auth-delegator --clusterrole=system:auth-delegator --serviceaccount=$policy_dir:$policy_dir || true
    kubectl -n $policy_dir create role secret-manager --verb=get,list,watch,create,update,patch,delete --resource=secrets || true
    kubectl -n $policy_dir create rolebinding $policy_dir-secret-manager --role secret-manager --serviceaccount=$policy_dir:$policy_dir || true

    # Configure the Role in Vault
    vault write auth/kubernetes/role/$policy_dir \
        bound_service_account_names=$policy_dir \
        bound_service_account_namespaces=$policy_dir \
        policies=$policy_dir \
        ttl=1h
done
