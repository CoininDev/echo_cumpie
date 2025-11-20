module c3_cumpie;

import std::io;
import lexer;
import std::core::string;
import std::collections::list;

fn int main(String[] args)
{
    if(args.len < 2) {
        io::printn("usage: cumpie path/to/file.echo");
        return 1;
    }

    String filename = (String) args[1];
    char[]? content = file::load_temp(filename);
    if(catch content) {
        io::printn("Impossível abrir esse arquivo");
        return 1;
    }
    
    List{Lexeme} lexs = lexer::lex_iter((String)content);
    io::printfn("%d", lexs.len());
    foreach(l : lexs) {
        io::printfn("%s: %s", l.type, l.data);
    }
	return 0;
}
