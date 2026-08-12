# Constats de développement

Constats initialement observés avec Janus 0.10.0, puis revérifiés après la
fusion des fonctionnalités correspondantes dans `janus/main`.

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

La conversion signée reste consignée comme caractéristique observée, pas comme
faille du langage. L'historique et le statut des deux propositions de syntaxe
figurent dans [`ISSUE_CANDIDATES.md`](ISSUE_CANDIDATES.md).
