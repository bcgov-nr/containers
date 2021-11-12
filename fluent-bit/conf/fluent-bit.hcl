vault {
  address = "https://vault-iit.apps.silver.devops.gov.bc.ca"
  renew_token = true
}

secret {
    no_prefix = true
    path = "apps/prod/fluent/fluent-bit"
}

exec {
  command = "/fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf"
  env {
    pristine = false
    custom = ["HTTP_PROXY=http://127.0.0.1:23128","NO_PROXY=https://vault-iit.apps.silver.devops.gov.bc.ca"]
  }
}
