#!/bin/sh -e

apk add --no-cache openssl

echo "Converting keystore to PKCS12"
echo "Input: ${KEYSTORE_INPUT_PEM_PATH}"
echo "Output: ${KEYSTORE_OUTPUT_PKCS12_PATH}"
openssl pkcs12 -export -out ${KEYSTORE_OUTPUT_PKCS12_PATH} -password pass:${STORE_PASSWORD} -name key -in ${KEYSTORE_INPUT_PEM_PATH}
echo "Keystore converted successfully"

echo "Converting truststore to PKCS12"
echo "Input: ${TRUSTSTORE_INPUT_PEM_PATH}"
echo "Output: ${TRUSTSTORE_OUTPUT_PKCS12_PATH}"
keytool -noprompt -import -alias ca -file ${TRUSTSTORE_INPUT_PEM_PATH} -keystore ${TRUSTSTORE_OUTPUT_PKCS12_PATH} -storetype PKCS12 -storepass ${STORE_PASSWORD}
echo "Truststore converted successfully"
