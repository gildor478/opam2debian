#!/bin/sh

set -e
set -x

unset OCAMLFIND_DESTDIR
unset OCAMLPATH
unset OCAMLFIND_LDCONF
OPAMNAME=le-gall.net-4.01

OPAMROOT=/opt/opam/$OPAMNAME
export OPAMROOT

LOCAL_OPAMROOT="$(pwd)/$OPAMNAME"

if ! [ -e "$LOCAL_OPAMROOT" ] ; then
  mkdir "$LOCAL_OPAMROOT"
fi

opam_run () {
  proot -b "$LOCAL_OPAMROOT:$OPAMROOT" opam "$@"
}

if ! [ -e "$LOCAL_OPAMROOT/state.cache" ] ; then
  opam_run init
fi

#opam_run list
#opam_run switch 4.01.0
opam_run install ounit -y
