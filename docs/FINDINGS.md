# Constats de développement

Constats observés avec le binaire local Janus 0.10.0, sans modification du compilateur.

## Littéraux hexadécimaux

- Repro : employer `uint(0x200)` dans un test.
- Résultat : `expected ')', found identifier`.
- Impact : faible ; les sources utilisent des constantes décimales.

## Opérateurs bit-à-bit

- Repro : employer `left | right`.
- Résultat : `[JLEX0001] unexpected character '|'`.
- Impact : faible pour ce projet ; les opérations CHIP-8 sont implémentées par
  division/modulo dans des fonctions dédiées.

## Conversion de `byte`

- Repro : convertir `byte(254)` en `uint` lors du décodage d'un opcode.
- Résultat observé : la valeur signée `-2` est étendue ; le motif doit être
  normalisé explicitement vers 0…255.
- Impact : moyen sans précaution, nul après centralisation dans `unsignedByte`.

Ces comportements sont consignés comme caractéristiques observées, pas comme
failles du langage.
