#!/bin/sh

echo "BOUNDARY-INIT: iniciando"

# source /vault/key/vault-token.txt
# export VAULT_TOKEN=$ROOT_TOKEN 

echo "BOUNDARY ENV FILE:"
cat /vault/key/boundary.env
echo "============"
export VAULT_TOKEN=$(cat /vault/key/boundary.env)

echo "Dumping env:"
echo "============"
env
echo "============"
boundary database init -config /boundary/config.hcl

echo "BOUNDARY-INIT: terminado"
