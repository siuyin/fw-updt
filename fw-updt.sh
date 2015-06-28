#!/bin/bash

function ipt_save {
  sudo iptables-save > ipt.sav
  sed -n -e '/\*nat/p'\
    -e '/^-A KUBE-NODEPORT-/p' \
    -e '$aCOMMIT' \
    ipt.sav > ipt.1
}

function ipt_remove_old {
  sed -n -e '/\*nat/p'\
    -e '/custom/s/^\-A/\-D/' \
    -e '/^\-D/p' \
    -e '$aCOMMIT' \
    ipt.1 >ipt.res
  sudo iptables-restore -n <ipt.res
}

function ipt_update {
  sed -e 's/default/custom/g' \
    -e '/custom\/wdotweb/s/--dport [0-9]\+/--dport 8188/' \
    -e '/custom\/postfix\:smtp/s/--dport [0-9]\+/--dport 25/' \
    -e '/custom\/postfix\:submission/s/--dport [0-9]\+/--dport 587/' \
    -e '/custom\/postfix\:imap/s/--dport [0-9]\+/--dport 143/' \
    -e '/custom\/postfix\:pop3/s/--dport [0-9]\+/--dport 110/' \
    -e '/custom\/roundcube\:http/s/--dport [0-9]\+/--dport 8180/' \
    -e '/custom\/roundcube\:https/s/--dport [0-9]\+/--dport 8143/' \
    ipt.1 >ipt.res
  sudo iptables-restore -n <ipt.res
}

ipt_save
ipt_remove_old
ipt_save
ipt_update

sudo iptables -tnat -S
rm ipt.sav ipt.1 ipt.res

