#
# criar entrada no Auth0 e copiar issuer, clientid e clientsecret.
#
boundary auth-methods create oidc \
  -name "local-auth0" \
  -api-url-prefix "http://localhost:9200" \
  -issuer "https://dev-xxxxxx.us.auth0.com/" \
  -signing-algorithm RS256 \
  -client-id <client-id> \
  -client-secret <client-secret>

export OIDCID=$(boundary auth-methods list -filter '"/item/name" == "local-auth0"' | grep " ID:" | awk '{print $2}')

boundary auth-methods change-state oidc -id $OIDCID -state active-public

boundary scopes update -primary-auth-method-id $OIDCID -id global

boundary authenticate oidc -auth-method-id $OIDCID
