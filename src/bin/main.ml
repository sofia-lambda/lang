open Lang
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

let () = 
  read_until_eof()
    |> Lexer.from_string Parser.program
    |> Ast.show_program
    |> print_endline
