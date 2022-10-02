PROMPT="%n@%m %~ %# "

credentials() {
  echo "Live Credentials -"
  echo "antergos: antergos // root: antergos"
  echo
}

main() {
  clear
  pfetch
  credentials
  cowsay \
    "Don't forget to set up Wi-Fi in the Settings app if required!"
}

main
