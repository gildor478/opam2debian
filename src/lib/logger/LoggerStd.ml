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
