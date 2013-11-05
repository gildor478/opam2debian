#!/bin/sh

set -e
if [ "x$DEBUG" = "xtrue" ]; then
  set -x
fi

# Safe guard against certain environment variable.
unset OCAMLFIND_DESTDIR
unset OCAMLPATH
unset OCAMLFIND_LDCONF

LOCAL_OPAMROOT="$1"
OPAMNAME=$(dirname "$LOCAL_OPAMROOT")
CHROOT_OPAMROOT=/opt/opam/$OPAMNAME

if ! [ -e "$LOCAL_OPAMROOT" ] ; then
  mkdir "$LOCAL_OPAMROOT"
fi

opam_run () {
  OPAMROOT="$CHROOT_OPAMROOT"
  export OPAMROOT
  proot -b "$LOCAL_OPAMROOT:$OPAMROOT" opam "$@"
}

if ! [ -e "$LOCAL_OPAMROOT/state.cache" ] ; then
  opam_run init --no-setup
fi

{% if compiler != "system" %}
opam_run switch {{compiler}}
{% else %}
# Using system compiler.
{% endif %}
{% for package in package_list %}
opam_run install {{package}} -y
{% endfor %}
