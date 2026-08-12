# Candidats et issues Janus

Janus8 transforme uniquement les limitations reproductibles et suffisamment
spécifiées en issues du langage Janus.

## Issues fermées et adoptées

### [Janus #205 — littéraux entiers hexadécimaux et binaires](https://github.com/cyril103/janus/issues/205) — fermée

Janus fournit désormais `0x`/`0b` et les séparateurs `_`. Janus8 a adopté cette
syntaxe dans les opcodes et dans les données binaires lisibles, par exemple
`uint(0xA20A)` et `byte(0b1111_0000)`.

### [Janus #206 — opérateurs entiers bit à bit et de décalage](https://github.com/cyril103/janus/issues/206) — fermée

Janus fournit désormais `&`, `|`, `^`, `<<` et `>>`. Janus8 les emploie pour le
décodage d'opcode, OR/AND/XOR, les shifts CHIP-8, le masque aléatoire et le
dessin des sprites ; les helpers arithmétiques de remplacement ont été retirés.

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
