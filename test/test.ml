(******************************************************************************)
(* opam2debian: Create Debian package that contains a set of OPAM packages.   *)
(*                                                                            *)
(* Copyright (C) 2013, Sylvain Le Gall                                        *)
(*                                                                            *)
(* This library is free software; you can redistribute it and/or modify it    *)
(* under the terms of the GNU Lesser General Public License as published by   *)
(* the Free Software Foundation; either version 2.1 of the License, or (at    *)
(* your option) any later version, with the OCaml static compilation          *)
(* exception.                                                                 *)
(*                                                                            *)
(* This library is distributed in the hope that it will be useful, but        *)
(* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *)
(* or FITNESS FOR A PARTICULAR PURPOSE. See the file COPYING for more         *)
(* details.                                                                   *)
(*                                                                            *)
(* You should have received a copy of the GNU Lesser General Public License   *)
(* along with this library; if not, write to the Free Software Foundation,    *)
(* Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA              *)
(******************************************************************************)

open OUnit2

let opam2debian = Conf.make_exec "opam2debian"

let simple = 
  "simple" >::
  (fun test_ctxt ->
     let tmpdir = bracket_tmpdir test_ctxt in
       assert_command ~ctxt:test_ctxt ~chdir:tmpdir
         (opam2debian test_ctxt)
         ["create";
          "--name"; "opam2debian-test";
          "--maintainer"; "Sylvain Le Gall <foo@bar.com>";
          "--verbose";
          "ounit"];
       (* TODO: test the result: list files in the debian archive. *)
  )

let () = 
  run_test_tt_main 
    ("opam2debian" >::: [simple])
