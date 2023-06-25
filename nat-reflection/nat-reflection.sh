#!/bin/bash

# Path to save rules
RULES_PATH="/etc/nat-reflection"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Create rules directory if it doesn't exist
mkdir -p "$RULES_PATH"

add_rule() {
  local ip=$1
  local dest=$2
  iptables -t nat -A PREROUTING -d "$ip" -j DNAT --to-destination "$dest"
  echo "$ip $dest" >> "$RULES_PATH/rules"
}

list_rules() {
  cat "$RULES_PATH/rules"
}

delete_rule() {
  local ip=$1
  local dest=$2
  if iptables -t nat -C PREROUTING -d "$ip" -j DNAT --to-destination "$dest" >/dev/null 2>&1; then
    iptables -t nat -D PREROUTING -d "$ip" -j DNAT --to-destination "$dest"
  fi
  sed -i "/$ip $dest/d" "$RULES_PATH/rules"
}

reload_rules() {
  while IFS=' ' read -r ip dest; do
    if iptables -t nat -C PREROUTING -d "$ip" -j DNAT --to-destination "$dest" >/dev/null 2>&1; then
      iptables -t nat -D PREROUTING -d "$ip" -j DNAT --to-destination "$dest"
    fi
    iptables -t nat -A PREROUTING -d "$ip" -j DNAT --to-destination "$dest"
  done < "$RULES_PATH/rules"
}

case "$1" in
  add)
    add_rule "$2" "$3"
    ;;
  list)
    list_rules
    ;;
  delete)
    delete_rule "$2" "$3"
    ;;
  reload)
    reload_rules
    ;;
  *)
    echo "Usage: $0 {add|list|delete|reload} [ip] [destination]"
    exit 1
esac
