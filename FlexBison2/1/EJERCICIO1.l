%{
#include <stdio.h>
%}

%%

[^ \t\n]+      { printf("BLOQUE: %s\n", yytext); }

[ \t]+         ;   /* ignorar espacios y tabs */

\n              { printf("FIN DE LINEA\n"); }

%%

int main(void)
{
    yylex();
    return 0;
}
