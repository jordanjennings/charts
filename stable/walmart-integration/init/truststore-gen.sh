#!/usr/bin/env bash

apk add --no-cache openssl coreutils

echo |  openssl s_client -showcerts -servername $WM_API_ENDPOINT -connect $WM_API_ENDPOINT:$WM_API_PORT 2> /dev/null | sed -n "/^-----BEGIN CERT/,/^-----END CERT/p" > $WM_CERTS_TMP 
csplit -z -f wm-crt- $WM_CERTS_TMP "/-----BEGIN CERTIFICATE-----/" "{*}"
for file in wm-crt-*; do 
    # INF-205: Attempt to delete the aliased certificate in the case it already exists
    keytool -delete -alias walmart-external-api-$file -keystore $TRUSTSTORE_JKS -storepass $TRUSTSTORE_SECRET || true
    keytool -import -noprompt -file $file -keystore $TRUSTSTORE_JKS -storepass $TRUSTSTORE_SECRET -alias walmart-external-api-$file
done

keytool -importkeystore -noprompt -srckeystore /opt/jdk/jre/lib/security/cacerts -destkeystore $TRUSTSTORE_JKS -srcstorepass changeit -deststorepass $TRUSTSTORE_SECRET
