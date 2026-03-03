%{
#include <stdio.h>
%}

%%

[^ \t\n]+      { printf("BLOQUE: %s", yytext); }

[ \t]+         ;   /* ignorar espacios y tabs */

\n              { printf("FIN DE LINEA"); }

%%

int main(void)
{
    yylex();
    return 0;
}
