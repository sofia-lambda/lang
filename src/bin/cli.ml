open Cmdliner
open Lang
(* Positional arguments: input files *)
let input_files =
  let doc = "The input source files" in
  let files_info = Arg.info [] ~docv:"FILES" ~doc in
  Arg.(value & pos_all string [] files_info)

(* --output / -o *)
let output =
  let doc = "Specify the name of the output executable." in
  Arg.(value & opt string "a.out" & info ["o"; "output"] ~docv:"OUTPUT" ~doc)

(* --backend *)
let backend =
  let doc = "Specify the backend to use, e.g., 'llvm' with triple targeting." in
  Arg.(value & opt string "llvm" & info ["backend"] ~docv:"BACKEND" ~doc)

(* --root *)
let root_dir =
  let doc = "Specify the root directory of the project." in
  Arg.(value & opt string "." & info ["root"] ~docv:"DIR" ~doc)

(* --stdin *)
let from_stdin =
  let doc = "Read input from standard input instead of files." in
  Arg.(value & flag & info ["stdin"] ~doc)

(* --json-output *)
let json_output =
  let doc = "Output in JSON format." in
  Arg.(value & flag & info ["json-output"] ~doc)

(* --module-tree-json *)
let module_tree_json =
  let doc = "Generate and output a JSON representation of the module tree." in
  Arg.(value & flag & info ["module-tree-json"] ~doc)

(* --threads *)
let threads =
  let doc = "Specify the number of threads to use for compilation." in
  Arg.(value & opt int 1 & info ["threads"] ~docv:"N" ~doc)

(* --dependencies *)
let dependencies =
  let doc = "Manage and handle dependencies." in
  Arg.(value & flag & info ["dependencies"] ~doc)

(* --features *)
let features =
  let doc = "Show the features supported by the tool." in
  Arg.(value & flag & info ["features"] ~doc)

let read_until_eof() =
  let buffer = Buffer.create 2048 in
  let rec read_loop() =
    let line = try Some(read_line()) with End_of_file -> None in
    match line with
    | None -> Buffer.contents buffer
    | Some(line) -> (
      Buffer.add_string buffer (line ^ "\n");
      read_loop()
    )
  in
  read_loop()

let parse_from_stdin() = 
  read_until_eof()
    |> Lexer.from_string Parser.program
    |> Ast.show_program
    |> print_endline;
  `Ok()

(* The main function that will run after parsing command line args *)
let run input_files output backend root_dir from_stdin json_output module_tree_json threads dependencies features =
  if features then (
    (* Just print available features and exit *)
    print_endline "Supported features: ...";
    `Ok ()
  ) else (
    if from_stdin then (
      parse_from_stdin ()
    ) else 
    begin
      Printf.printf "Input files: %s\n" (String.concat ", " input_files);
      Printf.printf "Output: %s\n" output;
      Printf.printf "Backend: %s\n" backend;
      Printf.printf "Root dir: %s\n" root_dir;
      Printf.printf "From stdin: %b\n" from_stdin;
      Printf.printf "JSON output: %b\n" json_output;
      Printf.printf "Module tree JSON: %b\n" module_tree_json;
      Printf.printf "Threads: %d\n" threads;
      Printf.printf "Dependencies: %b\n" dependencies;
      `Ok ()
    end
  )

(* Construct the Cmdliner term *)
let term =
  Term.(
    ret (const run
         $ input_files
         $ output
         $ backend
         $ root_dir
         $ from_stdin
         $ json_output
         $ module_tree_json
         $ threads
         $ dependencies
         $ features)
  )

(* Command information *)
let info =
  let doc = "A simple compiler that aims to compile." in
  let man = [
    `S Manpage.s_description;
    `P "This compiler reads one or more .ln source files, optionally from stdin, and produces an output executable. It also supports specifying backend, root directory, JSON output, and other features.";
    `S Manpage.s_options;
    `P "Use --help to see all available options.";
  ] in
  Cmd.info "lang" ~version:"0.1.0" ~doc ~exits:Cmd.Exit.defaults ~man

(* Main entry point *)
let main () = exit (Cmd.eval (Cmd.v info term))
