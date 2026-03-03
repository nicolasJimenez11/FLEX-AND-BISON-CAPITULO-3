%{
/* Librerias necesarias */
#include <stdio.h>     // Para imprimir en pantalla
#include <stdlib.h>    // Para usar malloc y exit
#include <string.h>    // Para usar funciones de manejo de strings
#include <ctype.h>     // Para convertir caracteres a minuscula

/* Tamano de la tabla hash */
#define HASHSIZE 101

/* 
Estructura de un simbolo dentro de la tabla.
Cada simbolo representa una palabra encontrada.
*/
struct symbol {
    char *name;            // Nombre de la palabra
    int count;             // Numero de veces que aparece
    struct symbol *next;   // Puntero al siguiente elemento (para manejar colisiones)
};

/* Tabla hash donde se guardan las palabras */
struct symbol *symtab[HASHSIZE] = {0};


/*
Funcion hash que calcula la posicion de una palabra
en la tabla hash.

La funcion convierte cada caracter a minuscula para
que palabras como "Hola" y "hola" sean consideradas iguales.
*/
unsigned symhash(char *sym) {
    unsigned int hash = 0;
    unsigned c;

    /* Recorre cada caracter de la palabra */
    while ((c = tolower(*sym++)))
        hash = hash * 31 + c;

    /* Se limita al tamano de la tabla */
    return hash % HASHSIZE;
}


/*
Funcion lookup:
Busca una palabra en la tabla hash.
Si la palabra ya existe, la devuelve.
Si no existe, la crea y la agrega a la tabla.
*/
struct symbol *lookup(char *sym) {
    unsigned hash = symhash(sym);   // Calcula la posicion hash
    struct symbol *sp;

    /* Recorre la lista enlazada en esa posicion */
    for (sp = symtab[hash]; sp; sp = sp->next)
        if (strcasecmp(sp->name, sym) == 0)  // Comparacion sin distinguir mayusculas
            return sp;

    /* Si la palabra no existe, se crea un nuevo nodo */
    sp = malloc(sizeof(*sp));
    if (!sp) {
        fprintf(stderr, "Error de memoria\n");
        exit(1);
    }

    /* Se guarda la palabra */
    sp->name = strdup(sym);

    /* Inicializa el contador */
    sp->count = 0;

    /* Inserta el nodo al inicio de la lista */
    sp->next = symtab[hash];
    symtab[hash] = sp;

    return sp;
}

%}

%%

/*
Regla de FLEX:
Detecta cualquier secuencia de letras (palabras).
*/
[a-zA-Z]+ {

    /* Busca la palabra en la tabla */
    struct symbol *s = lookup(yytext);

    /* Incrementa el contador de apariciones */
    s->count++;
}

/* Ignora espacios, tabulaciones y saltos de linea */
[ \t\n]+ ;

/* Ignora cualquier otro caracter */
. ;

%%

/*
Funcion principal del programa.
Aqui se ejecuta el analizador lexico.
*/
int main(void) {

    /* Ejecuta el analisis del texto */
    yylex();

    printf("\n--- TABLA DINAMICA ---\n");

    /*
    Recorre toda la tabla hash para imprimir
    las palabras encontradas y su numero de apariciones.
    */
    for (int i = 0; i < HASHSIZE; i++) {

        struct symbol *sp = symtab[i];

        while (sp) {
            printf("%s: %d\n", sp->name, sp->count);
            sp = sp->next;
        }
    }

    return 0;
}
