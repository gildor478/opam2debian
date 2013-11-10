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

(* TODO: move in a library and replace *)

let console_logger t level str =
  let prefix =
    match level with
      | `Debug -> "D: "
      | `Info -> "I: "
      | `Warning -> "W: "
      | `Error -> "E: "
  in
    prerr_endline (prefix^str)

let create verbose = 
 {
   Logger.verbose = verbose;
   output = console_logger;
 }

let args =
  let verbose = ref false in
    [
      "-verbose",
      Arg.Set verbose,
      " Output all logging messages."
    ],
    (fun () -> create !verbose)

let cmdliner_args docs = 
  let open Cmdliner in
  let doc = "Output all logging messages." in
    Arg.(value & flag & Arg.info ["v"; "verbose"] ~doc ~docs) 
