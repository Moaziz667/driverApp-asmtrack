# ASM Track — Application Chauffeur

> Application mobile compagnon de la plateforme [ASM Track](https://github.com/Moaziz667/asm-track)
> Mohamed Aziz Hadjkacem — ASM (All Soft Multimédia), Sfax

> **L'intégration continue tourne sur le GitLab auto-hébergé d'ASM.** GitHub n'exécute pas
> `.gitlab-ci.yml` : aucun workflow ne s'exécute ici. La définition du pipeline est dans
> [`.gitlab-ci.yml`](.gitlab-ci.yml).

---

## Aperçu

Le livreur est le seul utilisateur de la plateforme qui travaille sans garantie de réseau. Il entre
dans un sous-sol, traverse une zone sans couverture, arrive chez un client dont l'immeuble coupe le
signal — et doit malgré tout pouvoir encaisser, faire signer et repartir.

**C'est la contrainte qui structure toute l'application.** Le reste — listes, cartes, formulaires —
en découle.

---

## Le choix central : écrire d'abord en local

Une action du livreur n'attend jamais le réseau. Elle est écrite dans une file locale (Hive),
l'interface avance immédiatement, et un service de synchronisation rejoue la file quand la
connectivité revient.

```
geste du livreur ──→ file locale (Hive) ──→ interface mise à jour
                            │
                   connectivité retrouvée
                            │
                            └──→ rejeu vers l'API ──→ accusé ──→ retrait de la file
```

| Fichier | Rôle |
|---|---|
| `services/offline_queue_service.dart` | File des actions en attente, rejeu ordonné |
| `services/connectivity_service.dart` | Détection de la bascule hors-ligne / en ligne |
| `services/route_cache_service.dart` | Tournée du jour disponible sans réseau |
| `services/delivery_note_cache.dart` | Bons de livraison consultables hors-ligne |
| `services/token_storage.dart` | Jetons en stockage sécurisé du système |

Deux conséquences qui méritent d'être dites :

**L'horodatage est celui du geste, pas celui de l'envoi.** Une preuve de livraison signée à 14 h 03
dans un parking souterrain et transmise à 14 h 40 reste datée de 14 h 03. Dater à la réception
aurait produit des tournées incohérentes dès la première zone blanche.

**Le rejeu suppose un serveur idempotent.** Une file qui reprend après une coupure peut renvoyer une
action déjà reçue mais dont l'accusé s'est perdu. Sans déduplication côté serveur, un encaissement
serait compté deux fois.

---

## Fonctionnalités

| Module | Contenu |
|---|---|
| `auth` | Connexion OIDC via Keycloak (`flutter_appauth`), jetons en stockage sécurisé |
| `home` | Tableau de bord du jour, état de la file de synchronisation |
| `routes` | Tournée du jour, ordre des arrêts, navigation |
| `deliveries` | Cycle de vie d'une livraison, changements d'état, quantités partielles |
| `pod` | Preuve de livraison : signature manuscrite, photos, scan de code |
| `cash` | Encaissement contre remboursement |
| `profile` | Compte, langue, informations de version |

68 fichiers Dart dans `lib/`, 10 fichiers de tests.

---

## Stack

| Couche | Technologies |
|---|---|
| Cadre | Flutter (Dart 3.8), Riverpod pour l'état |
| Réseau | Dio, STOMP sur WebSocket pour le temps réel |
| Persistance locale | Hive, `flutter_secure_storage`, `shared_preferences` |
| Authentification | `flutter_appauth` — OIDC, Keycloak |
| Terrain | `geolocator`, `mobile_scanner`, `signature`, `image_picker` |
| Notifications | Firebase Messaging, notifications locales |
| Observabilité | Sentry (`sentry_flutter`, `sentry_dio`) |
| Internationalisation | `flutter_localizations`, `intl` |

---

## Intégration continue

Le dépôt n'avait pas de chaîne d'intégration : ses tests ne s'exécutaient que sur le poste du
développeur, donc uniquement quand il y pensait.

Les étapes suivent le coût croissant — ce qui peut échouer en quelques secondes passe avant ce qui
demande une compilation complète.

| Étape | Job | Rôle |
|---|---|---|
| `build` | `format` | `dart format --set-exit-if-changed`, bloquant |
| `build` | `analyze` | `flutter analyze`, bloquant sur `error` et `warning` seulement |
| `test` | `test` | Tests avec couverture, rapport traduit en JUnit pour l'onglet Tests |
| `test` | `coverage` | lcov traduit en Cobertura, annotation ligne à ligne sur les merge requests |
| `package` | `build-apk` | APK de release, sur la branche par défaut et les tags |

Trois détails qui ne se devinent pas :

- **L'image Flutter est épinglée** (`3.32.6`). Une image `latest` ferait changer le SDK sous les
  tests sans qu'aucun commit ne le demande.
- **`set -o pipefail` avant la traduction JUnit.** Sans lui, le code de sortie serait celui du
  traducteur — qui réussit parfaitement à traduire un rapport plein d'échecs. Le job passerait au
  vert avec des tests rouges dedans.
- **Le pourcentage de couverture est imprimé dans `script`, pas `after_script`.** Le second
  s'exécute même quand le job a échoué, et publierait un taux calculé sur un rapport incomplet.

L'analyse statique est volontairement moins stricte que le format : le projet compte une quarantaine
de remarques de niveau « info » — imports superflus, API dépréciées — qui n'empêchent rien de
fonctionner. Bloquer dessus rendrait le job rouge en permanence, donc illisible.

L'APK produit est signé avec la clé de débogage ; un APK de magasin exigerait un keystore en
variable protégée, ce qui n'est pas le rôle de ce dépôt.

---

## Démarrage

```bash
flutter pub get
flutter run
```

L'application attend une instance d'ASM Track accessible et un realm Keycloak configuré — voir le
[dépôt principal](https://github.com/Moaziz667/asm-track).

```bash
flutter test                 # tests
flutter analyze              # analyse statique
dart format lib test         # format
```

---

## Auteur

**Mohamed Aziz Hadjkacem** — [mohamedaziz.hadjkacem21@gmail.com](mailto:mohamedaziz.hadjkacem21@gmail.com)
