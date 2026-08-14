# Janus8

Janus8 est un émulateur CHIP-8 headless écrit entièrement en Janus 0.11.1.
Ce premier jalon charge une ROM binaire, exécute un nombre borné de cycles et
peut produire une trace et un état final déterministes.

## Utilisation

```sh
/opt/data/repos/janus/build/janus build
target/debug/janus8 jeu.ch8 --cycles 1000
target/debug/janus8 jeu.ch8 --cycles 20 --trace --dump-state state.txt --seed 42
```

Codes de sortie : `0` succès, `2` arguments invalides, `3` lecture impossible,
`4` ROM trop grande, `5` opcode/état d'exécution invalide, `6` écriture du dump
impossible. `--help` affiche l'usage. La graine vaut 1 par défaut.

Validation locale :

```sh
JANUS=/opt/data/repos/janus/build/janus
$JANUS fmt
$JANUS fmt --check
$JANUS check --all --deny-warnings
$JANUS test --fail-if-empty
$JANUS build
tests/native_syntax.sh
tests/native_syntax_mutation.sh
tests/smoke.sh
```

## Architecture et statut

- `chip8.core` : mémoire 4096 octets, V0–VF, I, PC initial à 512, pile de 16
  niveaux, timers, clavier 16 touches, framebuffer 64×32 et RNG à graine.
- `chip8.app` : arguments, `std.fs`, boucle bornée, trace, dump et diagnostics.
- `tests/` : tests `/// @test`, fixture libre générée par le projet et oracle.

Opcodes implémentés : `00E0`, `00EE`, `1NNN`, `2NNN`, `3XNN`, `4XNN`,
`5XY0`, `6XNN`, `7XNN`, `8XY0/1/2/3/4/5/6/7/E`, `9XY0`, `ANNN`, `BNNN`,
`CXNN`, `DXYN`, `EX9E/EXA1`, `FX07/0A/15/18/1E/29/33/55/65`.
Tout autre encodage retourne `UnsupportedOpcode`. Le dessin reboucle aux bords.

## Capacités Janus exercées

| Capacité | Usage |
| --- | --- |
| modules/classes/enums | séparation cœur/application et erreurs CHIP-8 |
| `Result`/`Option` | erreurs d'exécution, fichiers et arguments |
| `Array` | mémoire, registres, pile, touches et pixels |
| `filledArray` | initialisation compacte de la mémoire, des registres, des touches et des pixels |
| littéraux de tableaux typés | fonte CHIP-8 déclarative, copiée vers la mémoire au démarrage |
| motifs littéraux de `match` | décodage exhaustif des sous-opcodes `8XYN` avec fallback explicite |
| littéraux `0x`/`0b` | opcodes, adresses, masques, fonte et sprites lisibles |
| opérateurs bit à bit et décalages | décodage, logique, shifts, RNG et dessin natifs |
| ownership/destructeurs | libération déterministe des tableaux et fichiers |
| `std.fs`/`std.process`/`std.text` | ROM, CLI, parsing et dump |
| `/// @test` | tests unitaires natifs isolés |

## Limites connues

Pas d'affichage interactif, de son ni de cadence 60 Hz : les timers ne sont
décrémentés que par appel explicite du cœur. Le CLI headless n'injecte pas de
touches. Les quirks historiques ne sont pas configurables : les shifts utilisent
VX, `FX55/FX65` ne modifient pas I, et le dessin wrappe. La CI consomme
l'archive Linux officielle de Janus `v0.11.1`, vérifie son SHA-256 puis contrôle
l'identité structurée du compilateur (version, révision, canal, cible et état
propre). Elle vérifie aussi que Janus8 conserve les syntaxes natives adoptées.

## Licence

MIT, voir [LICENSE](LICENSE).
