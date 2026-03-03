%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define HASHSIZE 101

struct symbol {
    char *name;
    int count;
    struct symbol *next;
};

struct symbol *symtab[HASHSIZE] = {0};

/* Hash case-insensitive */
unsigned symhash(char *sym) {
    unsigned int hash = 0;
    unsigned c;

    while ((c = tolower(*sym++)))
        hash = hash * 31 + c;

    return hash % HASHSIZE;
}

/* Lookup con chaining */
struct symbol *lookup(char *sym) {
    unsigned hash = symhash(sym);
    struct symbol *sp;

    for (sp = symtab[hash]; sp; sp = sp->next)
        if (strcasecmp(sp->name, sym) == 0)
            return sp;

    /* No existe → crear nuevo */
    sp = malloc(sizeof(*sp));
    if (!sp) {
        fprintf(stderr, "Error de memoria\n");
        exit(1);
    }

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

[ \t\n]+ ;

. ;

%%

int main(void) {
    yylex();

    printf("\n--- TABLA DINÁMICA ---\n");

    for (int i = 0; i < HASHSIZE; i++) {
        struct symbol *sp = symtab[i];
        while (sp) {
            printf("%s: %d\n", sp->name, sp->count);
            sp = sp->next;
        }
    }

    return 0;
}
