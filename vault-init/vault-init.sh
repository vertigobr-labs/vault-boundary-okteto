#!/bin/sh

echo "VAULT-INIT: iniciando"

UNSEAL_KEY=
ROOT_TOKEN=
VAULT_TOKEN=

mkdir -p /vault/key

echo "Verificando init status..."

vault status
VAULT_STATUS=$?
if [ "$VAULT_STATUS" == "0" ]; then
  echo "VAULT-INIT: Vault encontrado e unsealed"
elif [ "$VAULT_STATUS" == "2" ]; then
  echo "VAULT-INIT: Vault encontrado e sealed"
  if $(vault status | grep -q '^Initialized.*false'); then
    echo "Vault NÃO está INITIALIZED, fazendo 'operator init'..."
    vault operator init -key-shares=1 -key-threshold=1 > /tmp/vault-init.txt
    cat /tmp/vault-init.txt
    UNSEAL_KEY=$(cat /tmp/vault-init.txt | grep '^Unseal Key 1:' | awk '{print $NF}')
    ROOT_TOKEN=$(cat /tmp/vault-init.txt | grep '^Initial Root Token:' | awk '{print $NF}')
    VAULT_TOKEN=$ROOT_TOKEN
    echo "Vault recém INITIALIZED, fazendo 'operator unseal'..."
    vault operator unseal "$UNSEAL_KEY"
    echo "IMPORTANTE: armazene as chaves acima para uso futuro"
    echo "ROOT_TOKEN=$ROOT_TOKEN" > /vault/key/vault-token.txt
    echo "UNSEAL_KEY=$UNSEAL_KEY" >> /vault/key/vault-token.txt
  else
    echo "Vault está INITIALIZED, fazendo 'operator unseal'..."
    cat /vault/key/vault-token.txt
    source /vault/key/vault-token.txt
    # UNSEAL_KEY=$(cat /tmp/vault-init.txt | grep '^Unseal Key 1:' | awk '{print $NF}')
    # ROOT_TOKEN=$(cat /tmp/vault-init.txt | grep '^Initial Root Token:' | awk '{print $NF}')
    VAULT_TOKEN="$ROOT_TOKEN"
    vault operator unseal "$UNSEAL_KEY"
  fi
else
  echo "VAULT-INIT: Vault não iniciado ou alcançado, saindo com erro $VAULT_STATUS"
  exit $VAULT_STATUS
fi

if [ -f /vault/key/vault-token.txt ]; then
  cat /vault/key/vault-token.txt
  source /vault/key/vault-token.txt
  export VAULT_TOKEN=$ROOT_TOKEN
fi

# echo "Verificando unseal status..."
# if $(vault status | grep -q '^Sealed.*true'); then
#   echo "Vault está SEALED, unsealing"
#   vault operator unseal $UNSEAL_KEY
# fi

echo "Criando policy boundary-controller"
vault policy write boundary-controller ./opt/vault/boundary-controller-policy.hcl

echo "Criando policy boundary-kms"
vault policy write boundary-kms ./opt/vault/boundary-kms-policy.hcl

if $(vault secrets list | grep -q '^transit/'); then
  echo "Transit Secret Engine já habilitado"
else
  echo "Habilitando Transit Secret Engine"
  vault secrets enable transit
  vault write -f transit/keys/boundary-root
  vault write -f transit/keys/boundary-recovery
  vault write -f transit/keys/boundary-worker-auth
fi

echo "Criando Token para o Boundary KMS"
vault token create \
  -no-default-policy=true \
  -policy="boundary-kms" \
  -orphan=true \
  -period=20m \
  -renewable=true > /tmp/boundary-init.txt
cat /tmp/boundary-init.txt
cat /tmp/boundary-init.txt | grep '^token ' | awk '{print $NF}' > /vault/key/boundary.env
#echo "$VAULT_TOKEN" > /opt/key/boundary-init.env
echo "BOUNDARY ENV FILE:"
cat /vault/key/boundary.env

echo "Criando Token para o Boundary"
vault token create \
  -no-default-policy=true \
  -policy="boundary-controller" \
  -orphan=true \
  -period=20m \
  -renewable=true

echo "VAULT-INIT: terminado, saindo..."
