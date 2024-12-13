%{
  open Ast
%}

%token <string> IDENT
%token <string> TYPE_IDENT
%token <int> INT
%token TYPE FN PUB LET MATCH TRAIT IMPL ON
%token EQUALS EOF DOT COMMA COLON
%token LPAREN RPAREN LBRACE RBRACE
%token ARROW FATARROW BAR LT GT

%start <Ast.program> program

%%


program: 
  | decls = list(decl) EOF {decls}

decl:
  | visibility = option(PUB); value = declaration_value; { 
      { value; visibility = (match visibility with | None -> Private | Some(_) -> Public) } 
    }

declaration_value:
  |t = type_decl { 
      let decl = t in
      decl
    }
  | f = fun_decl { f }

type_params:
  | LPAREN params = separated_list(COMMA, TYPE_IDENT) RPAREN { params }
  | { [] }  (* empty case for no type parameters *)

type_decl:
  | TYPE type_name = TYPE_IDENT params = type_params EQUALS type_expr = type_expr { 
      TypeAlias(type_name, params, type_expr) 
    }
  | TYPE type_name = TYPE_IDENT params = type_params EQUALS LBRACE field_decls = separated_list(COMMA, field_decl) RBRACE {
      StructDecl(type_name, params, field_decls)
    }
  | TYPE type_name = TYPE_IDENT params = type_params EQUALS constructors = separated_nonempty_list(BAR, constructor_decl) {
      EnumDecl(type_name, params, constructors)
    }

field_decl:
  | field_name = IDENT COLON field_type = type_expr { (field_name, field_type) }

constructor_decl:
  | constructor_name = TYPE_IDENT { (constructor_name, []) }
  | constructor_name = TYPE_IDENT LPAREN constructor_args = separated_list(COMMA, type_expr) RPAREN { (constructor_name, constructor_args) }

type_expr:
  | type_name = TYPE_IDENT { TyName(type_name) }
  | type_name = TYPE_IDENT LPAREN type_args = separated_list(COMMA, type_expr) RPAREN { TyApp(type_name, type_args) }
  | LPAREN type_exprs = separated_list(COMMA, type_expr) RPAREN ARROW return_type = type_expr { TyFun(type_exprs, return_type) }
  | t1 = type_expr ARROW t2 = type_expr { TyArrow(t1, t2) }

fun_decl:
  | FN name = IDENT LPAREN params = separated_list(COMMA, param_decl) RPAREN return_type = option(type_expr) body = block {
      FunDecl { name; params; return_type = (match return_type with | None -> TyName("Unit") | Some(t) -> t); body }
    }

param_decl:
  | param_name = IDENT COLON param_type = type_expr { (param_name, param_type) }

expr:
  | IDENT { Var($1) }
  | INT { Lit(LitInt($1)) }
  | e = expr LPAREN args = separated_list(COMMA, expr) RPAREN { Call(e, args) }
  

block:
  | LBRACE e = expr RBRACE { e }
