#!/bin/bash

# path to save rules
RULES_PATH="/etc/nat-reflection"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root"
  exit 1
fi

# Create rules directory if not exist
mkdir -p $RULES_PATH || { echo 'Error: Failed to create rules directory.'; exit 1; }

function add_rule() {
  local ip=$1
  local dest=$2
  iptables -t nat -A PREROUTING -d $ip -j DNAT --to-destination $dest || { echo "Error: Failed to add rule."; exit 1; }
  echo "$ip $dest" >> "$RULES_PATH/rules" || { echo 'Error: Failed to write rule to file.'; exit 1; }
  echo "Success: Rule added."
}

function list_rules() {
  cat "$RULES_PATH/rules" || { echo 'Error: Failed to list rules.'; exit 1; }
}

function delete_rule() {
  local ip=$1
  local dest=$2
  iptables -t nat -D PREROUTING -d $ip -j DNAT --to-destination $dest || { echo 'Error: Failed to delete rule.'; exit 1; }
  sed -i "/$ip $dest/d" "$RULES_PATH/rules" || { echo 'Error: Failed to delete rule from file.'; exit 1; }
  echo "Success: Rule deleted."
}

function reload_rules() {
  sleep 3
  while IFS=' ' read -r line; do
    IFS=' ' read -r ip dest <<<"$line"
    iptables -t nat -D PREROUTING -d $ip -j DNAT --to-destination $dest >/dev/null 2>&1
    iptables -t nat -A PREROUTING -d $ip -j DNAT --to-destination $dest || { echo "Error: Failed to reload rule."; exit 1; }
  done < "$RULES_PATH/rules"
  echo "Success: Rules reloaded."
}

case "$1" in
  add)
    add_rule $2 $3
    ;;
  list)
    list_rules
    ;;
  delete)
    delete_rule $2 $3
    ;;
  reload)
    reload_rules
    ;;
  *)
    echo "Usage: $0 {add|list|delete|reload} [ip] [destination]"
    exit 1
esac
