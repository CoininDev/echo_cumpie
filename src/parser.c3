import std::io;
import std::collections::list;
import lexer;

struct Node {
  List{Node} children;
  NodeType type;
  // just for values
  union data {
    int as_number;
    String as_string;
    Event as_event;
  }
}

struct Event {
  List{Node} fragments;
}

enum NodeType {
  PROGRAM,
  FUNCTION,

  // STATEMENTS
  WHEN_STMT,
  ASSIGN_STMT,
  FCALL_STMT,
  RETURN_STMT,
  EXPR_STMT,

  // VALUES
  IDENT,
  STRING_LIT,
  NUMBER_LIT,
  EVENT,
}

struct Parser {
  List{Lexeme} lexs;
  usz current;
}

// Parser errors
faultdef REACHED_END, UNEXPECTED_TOKEN;

fn Lexeme? Parser.next(Parser* p) {
  if(p.lexs.len() <= p.current) return REACHED_END?;
  p.current++;
  return p.lexs.get(p.current);
}

fn Lexeme? Parser.peek(Parser* p, int offset) {
  if(p.lexs.len() <= p.current + offset) return REACHED_END?;
  return p.lexs.get(p.current + offset);
}

fn Node Parser.parse_program(Parser* p, Lexeme[] lexs) {
  List{Node} functions;
  foreach(&lex : lexs) {
    if(lex.type == EOF) break;

    Node? f = parse_function();
    if(catch f) {
      io::printn("could not parse a function.");
    }
  }
  return {functions, PROGRAM};
}

fn Node? Parser.parse_function(Parser* p){
  String fname;
  List{Node} statements;
  Lexeme l = p.peek(0)!;
  if(l.data != "func") {
    io::printfn("UNEXPECTED: %s", l.type);
    return UNEXPECTED_TOKEN;
  }

  l = p.next()!;
  fname = l.data;

  l = p.next()!;
  //optional "do" keyword or ~ for block start
  if (l.data = "do" && l.type == TILDE) l = p.next()!;
  while(l.data != "func") {
    Node statement = parse_statement()!;
    statements.push(statement);
  }
}
