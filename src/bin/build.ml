(*
Copyright 2024 Lemonadic. All rights reserved.
Licensed under the Apache License, Version 2.0 as described in the file LICENSE.

Authors: Júnior Nascimento
*)
open Lang
open Sedlexing

type compiler_options = {
  input_files : string list;
  output : string;
  backend : string;
  root_dir : string;
  from_stdin : bool;
  json_output : bool;
  module_tree_json : bool;
  threads : int;
  dependencies : bool;
  features : bool;
}

let print_features ()  =
  print_endline "Supported features:";
  print_endline "- Compilation from files or stdin";
  print_endline "- Multiple backends (e.g., LLVM)";
  print_endline "- JSON output options";
  `Ok ()

let read_until_eof () =
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

let parse_from_stdin json_output =
  let str = read_until_eof () in
  let buf = Sedlexing.Utf8.from_string str in
  try
    let ast = MenhirLib.Convert.Simplified.traditional2revised Grammar.program (Lexer.provider buf) in
    if json_output then
      failwith "TODO implement json output"
    else
      print_endline (Ast.show_program ast);
      `Ok()
  with
    | Lexer.Invalid_token msg ->
      Printf.eprintf "Lexical error: %s at position %d\n" msg (lexeme_start buf);
      exit 1
    | Grammar.Error ->
      Printf.eprintf "Parse error starting at %d, ending at %d\n" (lexeme_start buf) (lexeme_end buf);
      exit 1

let compile options () =
    Printf.printf "Compiling files: %s\n" (String.concat ", " options.input_files);
    Printf.printf "Output executable: %s\n" options.output;
    Printf.printf "Backend: %s\n" options.backend;
    Printf.printf "Root directory: %s\n" options.root_dir;
    Printf.printf "JSON output: %b\n" options.json_output;
    Printf.printf "Module tree JSON: %b\n" options.module_tree_json;
    Printf.printf "Threads: %d\n" options.threads;
    Printf.printf "Dependencies: %b\n" options.dependencies;
    `Ok ()

let process options =
  match options with
  | { features = true; _ } ->  print_features ()
  | { from_stdin = true; json_output; _ } -> parse_from_stdin json_output
  | { input_files = []; _ } ->
      prerr_endline "Error: No input files provided.";
      `Error "No input files provided."
  | options -> compile options ()