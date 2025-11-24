module lexer;
import std::io;
import std::collections::list;
import std::ascii;
import std::core::array;

enum LexemeType
{
  KEYWORD,
  IDENT,     //[a-zA-Z_]+
  NUMBER,    //[0-9]+ (.[0-9])?
  STRING,    //"[any !"]*"
  L_BRACKET, //[
  R_BRACKET, //]
  L_BRACE,   //{
  R_BRACE,   //}
  TILDE,     //~
  COLON,     //:
  ADD,       //+
  ARROW,     //<-
  EOF,
}

fn List{String} keywords() {
  List{String} r;
  r.push("func");
  r.push("when");
  r.push("do");
  r.push("ok");
  return r;
}

struct Lexeme
{
  uint size;
  LexemeType type;
  String data;
}

fn List{Lexeme} lex_iter(String src)
{
  List{Lexeme} result = {};
  uint line = 0;

  StringIterator iter = src.iterator();

  while(iter.has_next())
  {
    Char32? c = iter.next();
    if(catch c) {
      io::printn("iter chegou ao fim.");
      break;
    }

    switch (c)
    {
      case ' ': case '\t': case '\r': continue;
      case '\n': line++;
      case '~': result.push({line, TILDE, ""});
      case '[': result.push({line, L_BRACKET, ""});
      case ']': result.push({line, R_BRACKET, ""});
      case '{': result.push({line, L_BRACE, ""});
      case '}': result.push({line, R_BRACE, ""});
      case ':': result.push({line, COLON, ""});
      case '+': result.push({line, ADD, ""});
      case '<':
        Char32? n = iter.peek();
        if(catch n) break;

        if(n == '-') {
          iter.next()!!;
          result.push({line, ARROW, ""});
        } else {
          io::printfn("unknown %c", c);
        }
      case '"':
        Char32? cu = iter.next();
        if(catch cu) break;
        String buf = "";

        while(cu != '"') {
          buf.tconcat({(char)cu});
          Char32? cuc = iter.next();
          if(catch cuc) break;
          cu = cuc;
        }
        result.push({line, STRING, buf});

      default:
        if(ascii::is_alpha_m(c)) {
          String buf = {(char)c};

          Char32? cu = iter.peek();
          if(catch cu) break;
          while(
                ascii::is_alpha_m(cu)
                || cu == '_'
                   && iter.has_next()
          ) {
            iter.next()!!;
            buf = buf.tconcat({(char)cu});
            Char32? cuc = iter.peek();
            if(catch cuc) break;
            cu = cuc;
          }

          if(keywords().contains(buf)) {
            result.push({line, KEYWORD, buf});
          } else {
            result.push({line, IDENT, buf});
          }

        }
        if(ascii::is_digit_m(c) || c == '.') {
          String buf = {(char)c};
          bool seen_dot = c == '.';

          Char32? cu = iter.next();
          if(catch cu) break;
          while(ascii::is_digit_m(cu)
                || (cu =='.' && !seen_dot)
                   && iter.has_next()
          ) {
            buf = buf.tconcat({(char)cu});
            Char32? cuc = iter.next();
            if(catch cuc) break;
            cu = cuc;
          }
        }
    }
  } // while has next


  result.push({line, EOF, ""});
  return result;
}
