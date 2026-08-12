# Candidats et issues Janus

Janus8 transforme uniquement les limitations reproductibles et suffisamment
spécifiées en issues du langage Janus.

## Issues ouvertes

### [Janus #205 — littéraux entiers hexadécimaux et binaires](https://github.com/cyril103/janus/issues/205)

Le code d’émulation manipule des adresses, opcodes, masques et sprites. Janus
0.10.0 impose leur notation décimale : `uint(41482)` remplace par exemple
`uint(0xA20A)`. L’issue propose `0x`/`0b`, les séparateurs `_`, des diagnostics
dédiés et la parité entre analyse, évaluation constante et exécution.

### [Janus #206 — opérateurs entiers bit à bit et de décalage](https://github.com/cyril103/janus/issues/206)

Janus8 doit actuellement reconstruire AND, OR, XOR, extraction de bits et
décalages avec divisions, modulos et boucles. L’issue propose `&`, `|`, `^`,
`<<` et `>>`, une sémantique définie aux frontières de largeur et une parité
compile-time/runtime sans poison LLVM.

## Constat non transformé en issue

La conversion de `byte` vers un type entier plus large étend le signe. Ce
comportement est documenté par Janus, qui fournit aussi `ubyte` et
`truncatingCast`. Il ne constitue donc pas un défaut ; Janus8 normalise les
octets binaires dans un helper central.

## Règle de suivi

Chaque nouvelle issue issue de ce banc d’essai doit comporter :

- une reproduction minimale exécutée sur une version Janus identifiée ;
- l’impact concret dans Janus8 ;
- une recherche de doublons dans le tracker Janus ;
- des critères d’acceptation couvrant les couches réellement concernées ;
- un lien retour depuis ce document.
