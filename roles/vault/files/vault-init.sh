#!/usr/bin/env sh

set -e

apk add jq

unseal () {
vault operator unseal $(grep 'Key 1:' /vault/file/keys | awk '{print $NF}') > /dev/null
vault operator unseal $(grep 'Key 2:' /vault/file/keys | awk '{print $NF}') > /dev/null
vault operator unseal $(grep 'Key 3:' /vault/file/keys | awk '{print $NF}') > /dev/null
}

init () {
vault operator init > /vault/file/keys
}

log_in () {
   export ROOT_TOKEN=$(grep 'Initial Root Token:' /vault/file/keys | awk '{print $NF}')
   vault login $ROOT_TOKEN > /dev/null
}

create_token () {
   vault token create -id $MY_VAULT_TOKEN > /dev/null
}

create_mount () {
   local mount="$1"
   local userpass_accessor="$2"
   vault secrets enable -path=${mount} kv-v2

   vault policy write ${mount}-rw -<<EOF
path "${mount}/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "auth/token/create" { 
    capabilities = ["create", "read", "update", "list"]
}
EOF
   vault policy write ${mount}-ro -<<EOF
path "${mount}/*" {
  capabilities = ["read", "list"]
}
path "auth/token/create" { 
    capabilities = ["create", "read", "update", "list"]
}
EOF
   
   vault write auth/userpass/users/${mount}-ro password=${mount}-ro-pwd
   vault write auth/userpass/users/${mount}-rw password=${mount}-rw-pwd

   export ro_entity_id=$(vault write -format=json identity/entity name="${mount}-ro" policies="default,${mount}-ro" | jq -r ".data.id")
   export rw_entity_id=$(vault write -format=json identity/entity name="${mount}-rw" policies="default,${mount}-rw" | jq -r ".data.id")

   vault write identity/entity-alias name="${mount}-ro" canonical_id=$ro_entity_id mount_accessor=$userpass_accessor
   vault write identity/entity-alias name="${mount}-rw" canonical_id=$rw_entity_id mount_accessor=$userpass_accessor
}

if [ -s /vault/file/keys ]; then
   unseal
else
   init
   unseal
   log_in
   create_token
   vault auth enable userpass
   export userpass_accessor=$(vault auth list -format=json | jq -r '.["userpass/"].accessor')
   create_mount "secrets" "$userpass_accessor"
fi

vault status > /vault/file/status

sleep infinity