
open OUnit2

let opam2debian = Conf.make_exec "opam2debian"

let simple = 
  "simple" >::
  (fun test_ctxt ->
     let tmpdir = bracket_tmpdir test_ctxt in
       assert_command ~ctxt:test_ctxt ~chdir:tmpdir
         (opam2debian test_ctxt) [];
       (* TODO: test the result: list files in the debian archive. *)
  )

let () = 
  run_test_tt_main 
    ("opam2debian" >::: [simple])
