
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
