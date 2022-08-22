RED='\u001b[31m'
GRN='\u001b[32m'
YEL='\u001b[33m'
BLU='\u001b[34m'
RST='\u001b[0m'

pinfo () {
  echo -e "$BLU$1$RST"
}

prompt () {
  echo -n -e "$BLU$1$RST"
}

psuccess () {
  echo -e "$GRN$1$RST"
}

pwarn () {
  echo -e "$YEL$1$RST"
}

perr () {
  echo -e "$RED$1$RST"
}

find_package_manager () {
  PACKAGE_MANAGERS='brew pacman'
  for PM in $PACKAGE_MANAGERS; do
    if [ $( which "$PM" ) ] ; then
      echo "$PM"
    fi
  done
  echo ""
}

prompt_lang_install () {
  pinfo "$PROMPT Do you want to set up $1? [Y/n] "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    pwarn "$PROMPT $1 setup skipped."
    return 1
  else
    return 0
  fi
}

pcmn() {
  sudo pacman --color=always --needed "$@"
}
