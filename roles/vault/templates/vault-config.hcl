ui = true

listener "tcp" {
  address     = "0.0.0.0:{{ vault_port }}"
  tls_disable = 1
}

storage "file" {
  path = "/vault/file"
}

api_addr = "http://{{ vault_host }}:{{ vault_port }}"

disable_mlock = "true"