# vault-boundary-okteto

Lab de Vault + Boundary no Okteto Cloud

Lab para executar ambos Vault e Boundary integrados via docker-compose (ambiente local)
ou via Okteto Cloud (ambiente remoto).

## Execução local (Docker Desktop)

```sh
docker-compose up
```

Para extrair dos logs os valores dos tokens gerados logo após a primeira execução:

```sh
# vault root token
docker-compose logs vault-init | grep "Initial Root Token:" | awk '{print $NF}'
# credenciais para o boundary
docker-compose logs boundary-init | grep "Login Name:" | awk '{print $NF}'
docker-compose logs boundary-init | grep "Password:" | awk '{print $NF}'
docker-compose logs boundary-init | grep "Auth Method ID:" | awk '{print $NF}'
```

Para utilizar a CLI do Vault com o root token:

```sh
# helper setenv script
. ./setenv.sh
export VAULT_ADDR=http://localhost:8200
vault status
```

Para utilizar a CLI do Boundary:

```sh
export BOUNDARY_ADDR=http://localhost:9200
boundary authenticate password \
    -auth-method-id=$BOUNDARY_AUTHID \
    -login-name=$BOUNDARY_LOGIN \
    -password=$BOUNDARY_PASSWORD
```

A Vault UI estará disponível em:

http://localhost:8200/ui

A UI do Boundary estará disponível em:

http://localhost:9200/


## Execução remota (Okteto Cloud)

```sh
# init okteto cli
okteto context use https://cloud.okteto.com
okteto kubeconfig
# deploy
okteto build # apenas uma vez
okteto deploy -f okteto-compose.yml
```

Para extrair dos logs os valores dos tokens gerados logo após a primeira execução:

```sh
# vault root token (trick to get successful init container, there could be many evicted before)
VAULT_INIT_CONTAINER=$(kubectl describe job vault-init | grep SuccessfulCreate | tail -n1 | awk '{print $7}')
BOUNDARY_INIT_CONTAINER=$(kubectl describe job boundary-init | grep SuccessfulCreate | tail -n1 | awk '{print $7}')
kubectl logs $VAULT_INIT_CONTAINER -c vault-init | grep "Initial Root Token:" | awk '{print $NF}'
# credenciais para o boundary
kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Login Name:" | awk '{print $NF}'
kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Password:" | awk '{print $NF}'
kubectl logs $BOUNDARY_INIT_CONTAINER -c boundary-init | grep "Auth Method ID:" | awk '{print $NF}'
```

Para utilizar a CLI do Vault com o root token:

```sh
# helper setenv script
. ./setenv.sh -k
export OKTETO_NS=$(okteto namespace list | grep Active | awk '{print $1}')
export VAULT_ADDR=https://vault-$OKTETO_NS.cloud.okteto.net
```

Para utilizar a CLI do Boundary:

```sh
export BOUNDARY_ADDR=https://boundary-$OKTETO_NS.cloud.okteto.net
boundary authenticate password \
    -auth-method-id=$BOUNDARY_AUTHID \
    -login-name=$BOUNDARY_LOGIN \
    -password=$BOUNDARY_PASSWORD
```

As UIs do Vault e do Boundary estarão disponíveis em:

https://vault-<namespace>.cloud.okteto.net/ui
https://boundary-<namespace>.cloud.okteto.net/ui

## Observações

As chaves para unseal e alguns tokens restritos estão sendo armazenados em volumes compartilhados
para facilitar a inicialização e reuso do ambiente. Isto não é desejável em ambiente real 
de produção!
