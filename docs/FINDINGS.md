# Constats de développement

Constats initialement observés avec Janus 0.10.0, puis revérifiés et adoptés
avec la release Janus 0.11.1.

## Littéraux hexadécimaux et binaires — résolu

- Ancienne reproduction : employer `uint(0x200)` dans un test produisait
  `expected ')', found identifier`.
- Résultat actuel : Janus accepte `0x`, `0b` et les séparateurs `_` ; Janus8 les
  utilise pour les opcodes, adresses, masques, fontes et sprites.
- Suivi : Janus #205 est fermée et la fonctionnalité est adoptée ici.

## Opérateurs bit-à-bit — résolu

- Ancienne reproduction : employer `left | right` produisait
  `[JLEX0001] unexpected character '|'`.
- Résultat actuel : Janus accepte `&`, `|`, `^`, `<<` et `>>` ; Janus8 les
  emploie directement pour le décodage, les instructions logiques, les shifts,
  le RNG et le dessin des sprites.
- Suivi : Janus #206 est fermée et la fonctionnalité est adoptée ici ; les
  anciens helpers arithmétiques ont été supprimés.

## Conversion de `byte`

- Repro : convertir `byte(254)` en `uint` lors du décodage d'un opcode.
- Résultat observé : la valeur signée `-2` est étendue ; le motif doit être
  normalisé explicitement vers 0…255.
- Impact : moyen sans précaution, nul après centralisation dans `unsignedByte`.

## Décodage par motifs littéraux — résolu

- Ancienne forme : la famille `8XYN` utilisait une chaîne de comparaisons
  `if`/`else if` sur le dernier nibble.
- Résultat actuel : Janus8 utilise un `match` exhaustif sur les sous-opcodes
  littéraux et un wildcard explicite pour les encodages non pris en charge.
- Suivi : Janus #210 est fermée et la fonctionnalité est adoptée ici.

## Données binaires déclaratives — résolu

- Ancienne forme : les 80 octets de la fonte CHIP-8 étaient installés par 80
  appels `set` indépendants.
- Résultat actuel : la fonte est un littéral `Array[byte]` typé, puis copiée
  vers sa plage mémoire réservée.
- Suivi : Janus #214 est fermée et la fonctionnalité est adoptée ici. Les
  fabriques de Janus #215 restent utilisées pour les grands tableaux remplis.

La conversion signée reste consignée comme caractéristique observée, pas comme
faille du langage. L'historique des fonctionnalités issues de ce banc d'essai
figure dans [`ISSUE_CANDIDATES.md`](ISSUE_CANDIDATES.md).
