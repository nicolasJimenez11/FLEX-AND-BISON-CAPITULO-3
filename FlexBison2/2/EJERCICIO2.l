%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define HASHSIZE 101

/* Estructura de símbolo */
struct symbol {
    char *name;
    int count;
    struct symbol *next;
};

/* Tabla hash */
struct symbol *symtab[HASHSIZE];

/* Hash ignorando mayúsculas */
unsigned symhash(char *sym) {
    unsigned int hash = 0;
    unsigned c;

    while ((c = tolower(*sym++)))
        hash = hash * 9 ^ c;

    return hash % HASHSIZE;
}

/* Buscar o crear símbolo */
struct symbol *lookup(char *sym) {
    struct symbol *sp;
    unsigned hash = symhash(sym);

    for (sp = symtab[hash]; sp; sp = sp->next)
        if (strcasecmp(sp->name, sym) == 0)
            return sp;

    sp = malloc(sizeof(*sp));
    sp->name = strdup(sym);
    sp->count = 0;
    sp->next = symtab[hash];
    symtab[hash] = sp;

    return sp;
}

%}

%%

[a-zA-Z]+ {
    struct symbol *s = lookup(yytext);
    s->count++;
}

[ \t\n]+   ;   /* ignorar espacios */

.          ;   /* ignorar otros caracteres */

%%

int main(void) {
    yylex();

    printf("\n CONCORDANCIA \n");

    for (int i = 0; i < HASHSIZE; i++) {
        struct symbol *sp = symtab[i];
        while (sp) {
            printf("%s: %d\n", sp->name, sp->count);
            sp = sp->next;
        }
    }

    return 0;
}
