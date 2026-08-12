# Journal de développement

Ce journal conserve les cycles RED/GREEN réellement exécutés avec Janus 0.10.0.

## Cycle 1 — API minimale du cœur

### RED

Les premiers tests décrivent un `Machine` démarrant à `0x200` et capable de
charger/exécuter `6XNN` puis `7XNN`. Ils importent volontairement le module
`chip8.core` avant son existence.

Commande exécutée :

```sh
/opt/data/repos/janus/build/janus test --fail-if-empty
```

Premier résultat (code 1), avant résolution de module : le parseur a signalé
`expected ')', found identifier` sur les deux premiers littéraux `0x...`.
Les tests ont été corrigés sans implémenter l'API, en remplaçant ces littéraux
par leurs équivalents décimaux, afin que le RED porte bien sur le module absent.

Deuxième résultat (code 1) : les deux tests ont échoué à la compilation avec
`[JMOD0001] cannot resolve imported module 'chip8.core'`; bilan `0 passed; 2 failed`.

### GREEN

Après création de `chip8.core` et adaptation aux octets signés, commande identique :
`2 passed; 0 failed` (code 0).

## Cycle 2 — groupes d'opcodes et limites

### RED

Ajout de tests déterministes pour contrôle, arithmétique, pile, timers, attente
clavier, BCD, transfert de registres, dessin/collision, ROM trop grande,
instruction non supportée et police intégrée. Résultat à consigner après exécution.
Premier lancement : code 1, `2 passed; 7 failed`. Les échecs ont mis en évidence
la police absente et plusieurs constantes opcode erronées dans les tests (corrigées
en vérifiant leur encodage), sans masquer les erreurs de l'émulateur.

Après intégration de la police et corrections de la spécification, un lancement
intermédiaire a donné `8 passed; 1 failed`; le dernier échec provenait encore de
constantes `6XNN` mal encodées dans le scénario `FX55/FX65`.

## Cycle 3 — application headless

### RED

Un test décrit `RunOptions` et `defaultOptions` en important volontairement
`chip8.app` avant sa création. Commande `janus test --fail-if-empty` à exécuter
et résultat à consigner ci-dessous.

Résultat (code 1) : `[JMOD0001] cannot resolve imported module 'chip8.app'`;
le reste du cœur était vert, bilan `9 passed; 1 failed`.

### GREEN

Après implémentation de `RunOptions`, du chargement `std.fs`, de la boucle,
de la trace et du dump : `10 passed; 0 failed` (code 0).

## Validation finale

Une première chaîne complète (`fmt`, `fmt --check`, `check --all
--deny-warnings`, `test --fail-if-empty`, `build`) a réussi avec 10 tests.
Le smoke réel a exécuté 10 cycles, terminé à PC 520 avec 2 pixels allumés,
et `diff` a confirmé le dump attendu. Un test de bornes pile/mémoire a ensuite
été ajouté pour fermer explicitement ces critères.
