#
# embarca CLI do Vault no Boundary (apenas para testes eventuais, habilitar para okteto)
#
FROM hashicorp/boundary:0.8

RUN wget -q https://releases.hashicorp.com/vault/1.10.3/vault_1.10.3_linux_amd64.zip && \
    unzip vault_1.10.3_linux_amd64.zip && \
    mv vault /usr/local/bin/ && \
    mkdir -p /boundary

ADD ./boundary-init/* /boundary/
