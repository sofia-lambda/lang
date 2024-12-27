open Parser

exception Invalid_token of string

(* Regular expressions for tokens *)
let whitespace = [%sedlex.regexp? Plus (' ' | '\n' | '\t' | '\r')]
let digit = [%sedlex.regexp? '0'..'9']
let lower = [%sedlex.regexp? 'a'..'z']
let upper = [%sedlex.regexp? 'A'..'Z']
let alpha = [%sedlex.regexp? lower | upper]
let identifier = [%sedlex.regexp? (lower | '_'), Star (alpha | digit | '_')]
let type_identifier = [%sedlex.regexp? upper, Star (alpha | digit | '_')]
let integer = [%sedlex.regexp? Plus digit]

(* Main tokenizer function *)
let rec tokenizer buf =
  match%sedlex buf with
  | whitespace -> tokenizer buf
  | "type" -> TYPE
  | "fn" -> FN
  | "pub" -> PUB
  | "let" -> LET
  | "match" -> MATCH
  | "trait" -> TRAIT
  | "impl" -> IMPL
  | "on" -> ON
  | "=>" -> FATARROW
  | "->" -> ARROW
  | "=" -> EQUALS
  | "." -> DOT
  | "," -> COMMA
  | ":" -> COLON
  | "{" -> LBRACE
  | "}" -> RBRACE
  | "(" -> LPAREN
  | ")" -> RPAREN
  | "|" -> BAR
  | "<" -> LT
  | ">" -> GT
  | identifier -> IDENT (Sedlexing.Utf8.lexeme buf)
  | type_identifier -> TYPE_IDENT (Sedlexing.Utf8.lexeme buf)
  | integer -> INT (int_of_string (Sedlexing.Utf8.lexeme buf))
  | eof -> EOF
  | _ -> raise (Invalid_token (Sedlexing.Utf8.lexeme buf))

(* Lexer interface functions *)
let provider buf () =
  let token = tokenizer buf in
  let start, stop = Sedlexing.lexing_positions buf in
  token, start, stop

let from_string f string =
  provider (Sedlexing.Utf8.from_string string) 
  |> MenhirLib.Convert.Simplified.traditional2revised f 

let%expect_test "parses public struct" =
  let program = from_string Parser.program "pub type User = {
  name : String,
  kind : Kind,
  id : Id
}
" in
  print_string (Ast.show_program program);
  [%expect{|
    [{ Ast.value =
       (Ast.StructDecl ("User", [],
          [("name", (Ast.TyName "String")); ("kind", (Ast.TyName "Kind"));
            ("id", (Ast.TyName "Id"))]
          ));
       visibility = Ast.Public }
      ]
    |}]