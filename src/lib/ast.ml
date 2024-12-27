type identifier = string [@@deriving show]

type literal =
  | LitInt of int
  | LitString of string
  | LitBool of bool
[@@deriving show]

type type_expr =
  | TyName of identifier
  | TyApp of identifier * type_expr list
  | TyFun of type_expr list * type_expr
  | TyArrow of type_expr * type_expr
[@@deriving show]

type pattern =
  | PConstructor of identifier * pattern list
  | PVariable of identifier
  | PLiteral of literal
[@@deriving show]

type expr =
  | Var of identifier
  | Lit of literal
  | Call of expr * expr list
  | Match of expr * (pattern * expr) list
  | BinOp of expr * string * expr
  | Let of identifier * expr
[@@deriving show]

type declaration_value =
  | TypeAlias of identifier * identifier list * type_expr
  | EnumDecl of identifier * identifier list * (identifier * type_expr list) list
  | StructDecl of identifier * identifier list * (identifier * type_expr) list
  | FunDecl of {
      name: identifier;
      params: (identifier * type_expr) list;
      return_type: type_expr;
      body: expr;
    }
  | TraitDecl of {
      name: identifier;
      type_params: (identifier * type_expr) list;
      methods: declaration_value list;
    }
  | ImplDecl of {
      trait_name: identifier;
      type_name: identifier;
      methods: declaration_value list;
    }
[@@deriving show]

type declaration_visibility =
  | Public
  | Private
[@@deriving show]

type declaration = {
  value: declaration_value;
  visibility: declaration_visibility;
}
[@@deriving show]

type program = declaration list [@@deriving show]
