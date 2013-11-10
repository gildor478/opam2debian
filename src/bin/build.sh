#!/bin/sh
################################################################################
#  opam2debian: Create Debian package that contains a set of OPAM packages.    #
#                                                                              #
#  Copyright (C) 2013, Sylvain Le Gall                                         #
#                                                                              #
#  This library is free software; you can redistribute it and/or modify it     #
#  under the terms of the GNU Lesser General Public License as published by    #
#  the Free Software Foundation; either version 2.1 of the License, or (at     #
#  your option) any later version, with the OCaml static compilation           #
#  exception.                                                                  #
#                                                                              #
#  This library is distributed in the hope that it will be useful, but         #
#  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
#  or FITNESS FOR A PARTICULAR PURPOSE. See the file COPYING for more          #
#  details.                                                                    #
#                                                                              #
#  You should have received a copy of the GNU Lesser General Public License    #
#  along with this library; if not, write to the Free Software Foundation,     #
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA               #
################################################################################

set -e
if [ "x$DEBUG" = "xtrue" ]; then
  set -x
fi

# Safe guard against certain environment variable.
unset OCAMLFIND_DESTDIR
unset OCAMLPATH
unset OCAMLFIND_LDCONF

LOCAL_OPAMROOT="$1"
OPAMNAME=$(basename "$LOCAL_OPAMROOT")
CHROOT_OPAMROOT=/opt/opam2debian/$OPAMNAME

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
