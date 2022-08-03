#!/bin/sh

echo "SETENV: utilitário para configurar o ambiente de trabalho"

if [ "$1" = "-k" ]; then
    # vault root token
    VAULT_INIT_CONTAINER=$(kubectl describe job vault-init | grep SuccessfulCreate | tail -n1 | awk '{print $7}')
    BOUNDARY_INIT_CONTAINER=$(kubectl describe job boundary-init | grep SuccessfulCreate | tail -n1 | awk '{print $7}')
    echo "VAULT_INIT_CONTAINER=$VAULT_INIT_CONTAINER"
    echo "BOUNDARY_INIT_CONTAINER=$BOUNDARY_INIT_CONTAINER"
    export VAULT_TOKEN=$(kubectl logs $VAULT_INIT_CONTAINER -c vault-init | grep "Initial Root Token:" | awk '{print $NF}')
    #export VAULT_TOKEN=$(kubectl logs job/vault-init -c vault-init | grep "Initial Root Token:" | awk '{print $NF}')
    # credenciais para o boundary
    export BOUNDARY_LOGIN=$(kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Login Name:" | awk '{print $NF}')
    export BOUNDARY_PASSWORD=$(kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Password:" | awk '{print $NF}')
    export BOUNDARY_AUTHID=$(kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Auth Method ID:" | awk '{print $NF}')
else
    # vault root token
    export VAULT_TOKEN=$(docker-compose logs vault-init | grep "Initial Root Token:" | awk '{print $NF}')
    # credenciais para o boundary
    export BOUNDARY_LOGIN=$(docker-compose logs boundary-init | grep "Login Name:" | awk '{print $NF}')
    export BOUNDARY_PASSWORD=$(docker-compose logs boundary-init | grep "Password:" | awk '{print $NF}')
    export BOUNDARY_AUTHID=$(docker-compose logs boundary-init | grep "Auth Method ID:" | awk '{print $NF}')
fi
