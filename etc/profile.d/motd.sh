if [ ! -z "$TERM" -a "$TERM" != "dumb" ]; then
  source /etc/os-release
  echo "You are using $PRETTY_NAME | $HOME_URL"
fi
