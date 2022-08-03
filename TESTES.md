# may convert this to terraform in the future

# new org
boundary scopes create -name vertigo -description "Vertigo org scope"
export ORGID=$(boundary scopes list -filter '"/item/name" == "vertigo"' | grep " ID:" | awk '{print $2}')
echo "ORGID=$ORGID"

# new project
boundary scopes create -name demo-boundary -description "Demo Vault + Boundary" -scope-id $ORGID
export PRJID=$(boundary scopes list -scope-id $ORGID -filter '"/item/name" == "demo-boundary"' | grep " ID:" | awk '{print $2}')
echo "PRJID=$PRJID"

# new host catalog
boundary host-catalogs create static -name "demo-targets" -description "Targets para demo" -scope-id $PRJID
export CATID=$(boundary host-catalogs list -scope-id $PRJID -filter '"/item/name" == "demo-targets"' | grep " ID:" | awk '{print $2}')
echo "CATID=$CATID"

# new host set (ssh hosts)
boundary host-sets create static -name ssh-hosts -description "SSH demo hosts" -host-catalog-id $CATID
export SETID=$(boundary host-sets list -host-catalog-id $CATID -filter '"/item/name" == "ssh-hosts"' | grep " ID:" | awk '{print $2}')
echo "SETID=$SETID"

# new static host (sshd)
boundary hosts create static -name "simple-ssh" -description "Simple SSH demo host" -address "test-sshd" -host-catalog-id $CATID
export HOSTID=$(boundary hosts list -host-catalog-id $CATID -filter '"/item/name" == "simple-ssh"' | grep " ID:" | awk '{print $2}')
echo "HOSTID=$HOSTID"
boundary host-sets add-hosts -host $HOSTID -id $SETID

# new target (ssh)
boundary targets create tcp -default-port 22 -name ssh-target -description "SSH Target (port 22)" -scope-id $PRJID
export TGTID=$(boundary targets list -scope-id $PRJID -filter '"/item/name" == "ssh-target"' | grep " ID:" | awk '{print $2}')
echo "TGTID=$TGTID"
boundary targets set-host-sets -id $TGTID -host-set $SETID


# HTTP HOST

# new host set (http hosts)
boundary host-sets create static -name http-hosts -description "HTTP demo hosts" -host-catalog-id $CATID
export SETID2=$(boundary host-sets list -host-catalog-id $CATID -filter '"/item/name" == "http-hosts"' | grep " ID:" | awk '{print $2}')
echo "SETID2=$SETID2"

# new static host (http)
boundary hosts create static -name "simple-http" -description "Simple HTTP demo host" -address "test-whoami" -host-catalog-id $CATID
export HOSTID2=$(boundary hosts list -host-catalog-id $CATID -filter '"/item/name" == "simple-http"' | grep " ID:" | awk '{print $2}')
echo "HOSTID2=$HOSTID2"
boundary host-sets add-hosts -host $HOSTID2 -id $SETID2

# new target (http)
boundary targets create tcp -default-port 80 -name http-target -description "HTTP Target (port 80)" -scope-id $PRJID
export TGTID2=$(boundary targets list -scope-id $PRJID -filter '"/item/name" == "http-target"' | grep " ID:" | awk '{print $2}')
echo "TGTID2=$TGTID2"
boundary targets set-host-sets -id $TGTID2 -host-set $SETID2

# TESTANDO

# testing ssh (senha secret)
boundary connect ssh -target-id $TGTID -- -l user

# testing http
boundary connect http -target-id $TGTID2 -scheme http
