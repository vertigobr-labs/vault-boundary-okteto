#!/bin/sh

echo "BOUNDARY-START: iniciando"

echo "BOUNDARY ENV FILE:"
cat /vault/key/boundary.env
echo "============"

export VAULT_TOKEN=$(cat /vault/key/boundary.env)
echo "Dumping env:"
echo "============"
env
echo "============"

# echo "Testando credenciais do boundary"
# TEXT=$(vault write -field=ciphertext transit/encrypt/boundary-root plaintext=$(echo OIOIOI | base64))
# echo "TEXT: $TEXT"
# vault write -field=plaintext transit/decrypt/boundary-root ciphertext="$TEXT" | base64 -d
# echo "============"

boundary server -config /boundary/config.hcl

echo "BOUNDARY-START: terminado"
