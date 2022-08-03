# This is VKPR default configuration provided for our Docker image. It's meant to
# be a starting point and to help new users get started. It uses Vault transit keys.

disable_mlock = true

controller {
  name = "vkpr-controller"
  description = "VKPR default controller"

  database {
    # This configuration setting requires the user to execute the container with the URL as an env var
    # to connect to the Boundary postgres DB.
    #
    # Example:
    # BOUNDARY_POSTGRES_URL=postgresql://user:password@hostname:5432/database?sslmode=disable
    #
    url = "env://BOUNDARY_POSTGRES_URL"
  }

  public_cluster_addr = "env://HOSTNAME"
}

worker {
  name = "vkpr-worker"
  description = "VKPR default worker"
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "cluster"
  tls_disable   = true 
}

listener "tcp" {
  address = "0.0.0.0"
  purpose       = "proxy"
  tls_disable   = true 
}

# Root KMS configuration block: this is the root key for Boundary
kms "transit" {
  purpose            = "root"
  address            = "http://vault:8200"
  disable_renewal    = "false"
  // Key configuration
  key_name           = "boundary-root"
  mount_path         = "transit/"
  namespace          = "ns1/"
}

# Recovery
kms "transit" {
  purpose            = "recovery"
  address            = "http://vault:8200"
  disable_renewal    = "false"
  // Key configuration
  key_name           = "boundary-recovery"
  mount_path         = "transit/"
  namespace          = "ns1/"
}

# Worker auth
kms "transit" {
  purpose            = "worker-auth"
  address            = "http://vault:8200"
  disable_renewal    = "false"
  // Key configuration
  key_name           = "boundary-worker-auth"
  mount_path         = "transit/"
  namespace          = "ns1/"
}
