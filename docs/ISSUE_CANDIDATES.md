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

### [Janus #210 — motifs littéraux et gardes de `match`](https://github.com/cyril103/janus/issues/210) — fermée

Janus8 emploie des motifs `uint(...)` et un wildcard pour décoder la famille
`8XYN`. Le fallback préserve le diagnostic `UnsupportedOpcode` pour les nibbles
inconnus, tandis que les tests d'opcodes couvrent les neuf branches reconnues.

### [Janus #214 — littéraux de tableaux typés](https://github.com/cyril103/janus/issues/214) — fermée

La fonte CHIP-8 de 80 octets est désormais déclarée comme un littéral
`Array[byte]`, ce qui rend ses seize glyphes lisibles comme un bloc de données
binaire et supprime 80 initialisations impératives indépendantes.

### [Janus #215 — fabriques de tableaux](https://github.com/cyril103/janus/issues/215) — fermée

Janus8 utilise `filledArray` pour la RAM, les registres, les touches et le
framebuffer. Les anciens helpers de remplissage manuel ont été supprimés.

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
