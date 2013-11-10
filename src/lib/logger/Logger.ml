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
type level = [`Debug|`Info|`Warning|`Error]
type t = 
  {
    verbose: bool;
    output: t -> level -> string -> unit
  }

let log t level str =
  if level = `Error || level = `Warning || t.verbose then begin
    let buff = Buffer.create (String.length str) in
    let flush () =
      t.output t level (Buffer.contents buff);
      Buffer.clear buff
    in
      String.iter 
        (function
           | '\n' -> flush ()
           | c -> Buffer.add_char buff c)
        str;
      if Buffer.length buff > 0 then
        flush ()
  end

let logf t level fmt =
  Printf.ksprintf (log t level) fmt

let debugf t fmt = logf t `Debug fmt
let infof t fmt = logf t `Info fmt
let warningf t fmt = logf t `Warning fmt
let errorf t fmt = logf t `Error fmt

let null_logger level str =
  ()
