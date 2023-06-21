#!/bin/bash

# path to save rules
RULES_PATH="/etc/nat-reflection"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Create rules directory if not exist
mkdir -p $RULES_PATH

function add_rule() {
  local ip=$1
  iptables -t nat -I OUTPUT -d $ip -j DNAT --to-destination 127.0.0.1
  echo $ip >> "$RULES_PATH/rules"
}

function list_rules() {
  cat "$RULES_PATH/rules"
}

function delete_rule() {
  local ip=$1
  iptables -t nat -D OUTPUT -d $ip -j DNAT --to-destination 127.0.0.1
  sed -i "/$ip/d" "$RULES_PATH/rules"
}

function reload_rules() {
  while IFS= read -r ip; do
    if iptables -t nat -C OUTPUT -d $ip -j DNAT --to-destination 127.0.0.1 >/dev/null 2>&1; then
      iptables -t nat -D OUTPUT -d $ip -j DNAT --to-destination 127.0.0.1
    fi
    iptables -t nat -I OUTPUT -d $ip -j DNAT --to-destination 127.0.0.1
  done < "$RULES_PATH/rules"
}

case "$1" in
  add)
    add_rule $2
    ;;
  list)
    list_rules
    ;;
  delete)
    delete_rule $2
    ;;
  reload)
    reload_rules
    ;;
  *)
    echo "Usage: $0 {add|list|delete|reload} [ip]"
    exit 1
esac