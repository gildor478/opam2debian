
open Jg_types

type conf =
    {
      name: string;
      config_file: string option;
      logger: Logger.t;
    }

module MapString = Map.Make(String)
module SetString = Set.Make(String)

let generate_file conf fn content replace =
  let fn = FilePath.make_filename fn in
  let dn = Filename.dirname fn in
  let env =
    {
      autoescape = false;
      template_dirs = [];
      filters = [];
      extensions = [];
      compiled = false;
    }
  in
  let content' = Jg_template.from_string ~models:replace ~env content in
  let () =
    Logger.debugf conf.logger "Generated file '%s' content:" fn;
    Logger.debugf conf.logger "%s" content'
  in

  let () =
    if not (Sys.file_exists dn) then begin
      Logger.infof conf.logger "Creating directory '%s'." dn;
      FileUtil.mkdir ~parent:true dn
    end
  in

    Logger.infof conf.logger "Generating file '%s'." fn;
    let chn_out = open_out fn in
      output_string chn_out content';
      close_out chn_out

let system_compiler = "system"

let add_build_depends_of_package package set =
  set

let add_depends_of_package package set =
  set

let maintainer_default =
  try
    Some
      (Printf.sprintf "%s <%s>"
         (Sys.getenv "DEBFULLNAME")
         (Sys.getenv "DEBEMAIL"))
  with Not_found ->
    None

let distribution_default =
  let chn = Unix.open_process_in "lsb_release -c -s" in
  let distribution = input_line chn in
    match Unix.close_process_in chn with
      | Unix.WEXITED 0 -> Some distribution
      | _ -> None

let version_default =
  CalendarLib.Printer.Calendar.sprint "%Y%m%d" (CalendarLib.Calendar.now ())

let system_compiler_version () =
  let chn = Unix.open_process_in "ocamlc -version" in
  let version = input_line chn in
    match Unix.close_process_in chn with
      | Unix.WEXITED 0 -> version
      | _ ->
          failwith
            "Unable to guess ocaml system version (using 'ocamlc -version')."

type create_data =
    {
      compiler: string;
      package_list: string list;
      build: bool;
      maintainer: string;
      homepage: string;
      distribution: string;
      version: string;
    }

let create conf data =
  let () =
    if data.package_list = [] then
      failwith "You must at least define one package to build."
  in

  let extra_build_depends =
    let package_build_depends =
      List.fold_left
        (fun set package -> add_build_depends_of_package package set)
        SetString.empty data.package_list
    in
      SetString.elements package_build_depends
  in

  let extra_depends =
    let package_depends =
      List.fold_left
        (fun set package -> add_depends_of_package package set)
        SetString.empty data.package_list
    in
    let package_depends =
      if data.compiler = system_compiler then
        SetString.add
          ("ocaml-nox-"^(system_compiler_version ()))
          package_depends
      else
        package_depends
    in
      SetString.elements package_depends
  in

  let date_rfc_2822 =
    CalendarLib.Printer.Calendar.sprint "%a, %d %b %Y %T %z"
      (CalendarLib.Calendar.now ())
  in


  let topdir = conf.name in

  let gen ?(exec=false) fn content =
    let tlist_string_of_list lst = Tlist (List.map (fun s -> Tstr s) lst) in
    let replace =
      [
        "name", Tstr conf.name;
        "compiler", Tstr data.compiler;
        "maintainer", Tstr data.maintainer;
        "homepage", Tstr data.homepage;
        "extra_build_depends", tlist_string_of_list extra_build_depends;
        "extra_depends", tlist_string_of_list extra_depends;
        "package_list", tlist_string_of_list data.package_list;
        "version", Tstr data.version;
        "date_rfc_2822", Tstr date_rfc_2822;
        "distribution", Tstr data.distribution;
      ]
    in
    generate_file conf (topdir :: fn) content replace;
    if exec then
      Unix.chmod (FilePath.make_filename (topdir :: fn)) 0o755
  in

    Logger.infof conf.logger "Creating package %S in directory '%s'."
      conf.name topdir;
    gen ~exec:true ["build.sh"] Data.build_sh;
    gen ["Makefile"] Data.makefile;
    gen ["debian"; "changelog"] Data.debian_changelog;
    gen ["debian"; "compat"] Data.debian_compat;
    gen ["debian"; "control"] Data.debian_control;
    gen ["debian"; "copyright"] Data.debian_copyright;
    gen ["debian"; "dirs"] Data.debian_dirs;
    gen ["debian"; "lintian-overrides"] Data.debian_lintian_overrides;
    gen ~exec:true ["debian"; "rules"] Data.debian_rules;
    gen ["debian"; "source"; "format"] Data.debian_source_format;
    begin
      let command =
        if data.build then
          Printf.sprintf "cd %s && debuild --no-lintian -uc -us" topdir
        else
          Printf.sprintf "dpkg-source -b %s" topdir
      in
        match Sys.command command with
          | 0 -> ()
          | n ->
              failwith
                (Printf.sprintf
                   "Command '%s' exited with code %d."
                   command n)
    end;
    FileUtil.rm ~recurse:true [topdir]

let init_env conf =
  print_endline "init_env"

open Cmdliner

let copts verbose config_file name =
  {
    name = name;
    config_file;
    logger = LoggerStd.create verbose;
  }

let copts_sect = "COMMON OPTIONS"

let copts_t =
  let docs = copts_sect in
  let config_file =
    let doc = "Read configuration from an ini file." in
    Arg.(value & opt (some file) None & info ["config-file"] ~docs ~doc)
  in
  let name_arg =
    let doc = "Name of the target debian package." in
    Arg.(required & opt (some string) None & info ["name"] ~docs ~doc)
  in
  Term.(pure copts $ LoggerStd.cmdliner_args docs $ config_file $ name_arg)

let create_cmd =
  let compiler =
    let doc = "Compiler version to use." in
    Arg.(value & opt string system_compiler & info ["compiler"] ~doc)
  in
  let build =
    let doc = "Not only create the source package, build it also." in
    Arg.(value & flag & info ["build"] ~doc)
  in
  let maintainer =
    let doc = "Fullname and email address." in
    Arg.(required & opt (some string) maintainer_default &
           info ["maintainer"] ~doc ~docv:"Joe Smith <joe@acme.com>")
  in
  let homepage =
    let doc = "Homepage about the generated package." in
    Arg.(value & opt string "" &
           info ["homepage"] ~doc ~docv:"http://acm.com/")
  in
  let distribution =
    let doc = "Which Debian/Ubuntu distribution to target." in
    Arg.(required & opt (some string) distribution_default &
           info ["distribution"] ~doc)
  in
  let version =
    let doc = "Package version." in
    Arg.(value & opt string version_default &
           info ["version"] ~doc)
  in
  let package_list =
    Arg.(value & (pos_all string) [] & info [] ~docv:"PKG")
  in
  let doc = "create a Debian source package containing all OPAM packages." in
  let man =
    [`S "DESCRIPTION";
     `P "Create a Debian source package. The list of package defines which \
         OPAM packages should be built by default."]
  in
  let f conf compiler package_list build maintainer homepage
        distribution version =
    create conf
      {compiler; package_list; build; maintainer; homepage;
       distribution; version}
  in
  Term.(pure f $ copts_t $ compiler $ package_list $ build $ maintainer
          $ homepage $ distribution $ version),
  Term.info "create" ~sdocs:copts_sect ~doc ~man

let init_env_cmd =
  let doc =
    "setup the environment to use the given opam2debian generated package."
  in
  let man =
    [`S "DESCRIPTION";
     `P "Initialize the environment just like OPAM recommend using the given \
         opam2debian generated package. This command may recommend you to edit \
         some files."]
  in
    Term.(pure init_env $ copts_t),
    Term.info "init-env" ~sdocs:copts_sect ~doc ~man

let default_cmd =
  Term.(ret (pure (fun _ -> `Help (`Pager, None)) $ copts_t)),
  Term.info "opam2debian" ~version:"TODO"

let () =
  match Term.eval_choice default_cmd [create_cmd; init_env_cmd] with
    | `Error _ -> exit 1
    | _ -> ()
