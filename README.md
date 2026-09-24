# Hamanieh Flash.net — App Flutter

Structure de base générée à partir de votre mockup. iOS + Android, une seule base de code.

## Démarrage

```bash
flutter pub get
flutter run
```

## Structure du projet

```
lib/
  main.dart                    # Point d'entrée
  theme/app_theme.dart         # Couleurs et style (charte bleue)
  models/models.dart           # Article, VideoItem, EventItem, PhotoItem, RadioProgram
  services/api_service.dart    # ⚠️ Connexion à VOTRE backend — à configurer
  widgets/hf_app_bar.dart      # Barre supérieure commune (logo, menu, cloche)
  screens/
    main_navigation.dart       # Barre de navigation (5 onglets)
    home_screen.dart           # 1. Accueil
    radio_screen.dart          # 2. Radio en direct
    videos_screen.dart         # 3. Hamanieh TV / YouTube
    news_screen.dart           # 4. Actualités Côte d'Ivoire
    events_screen.dart         # 5. Événements à couvrir
    photos_screen.dart         # 6. Photos des événements
    contact_screen.dart        # 7. Contact & Publicité
    notifications_screen.dart  # 8. Notifications
    more_menu_screen.dart      # Menu "Plus" (regroupe 5 à 8)
```

## Navigation

La barre du bas a 5 onglets : **Accueil, Radio, Actualités, Vidéos, Plus**.
Le bouton **Plus** ouvre un menu vers Événements, Photos, Contact et Notifications
(pour rester simple à l'usage tout en gardant les 8 écrans du mockup).

## ⚠️ Étape indispensable avant de lancer l'app

Votre site hamanieh-flash.net est un site PHP classique (pages `.php`) qui ne
renvoie pas de JSON. Un dossier séparé **hamanieh_flash_api** vous est fourni
avec des scripts PHP (`articles.php`, `article_detail.php`, `radio.php`,
`videos.php`, `events.php`, `photos.php`, `contact.php`) à déposer dans un
dossier `/api` sur votre serveur, à côté de vos fichiers existants.

Avant de les mettre en ligne :
1. Ouvrez `api/db.php` et renseignez les vrais identifiants de connexion à
   votre base de données (hôte, nom de la base, utilisateur, mot de passe —
   normalement déjà présents dans un fichier de config existant sur le site).
2. Dans chaque script (`articles.php`, `videos.php`, `events.php`,
   `photos.php`), vérifiez que les noms de table et de colonnes utilisés
   correspondent à votre base réelle (ils sont indiqués en commentaire en
   haut de chaque fichier) — adaptez-les si besoin.
3. Déposez le dossier `api/` à la racine du site, de sorte que
   `https://hamanieh-flash.net/api/articles.php` réponde bien en JSON.

Côté app, `lib/services/api_service.dart` pointe déjà vers
`https://hamanieh-flash.net/api`.

## Prochaines étapes suggérées

1. Adapter et mettre en ligne les scripts PHP de `hamanieh_flash_api/`.
2. Tester chaque écran une fois les endpoints en ligne (Accueil, Actualités,
   Radio, Vidéos, Événements, Photos).
3. ~~Configurer Firebase Cloud Messaging pour les notifications push réelles.~~
   Fait — voir la section "Notifications push (Firebase)" ci-dessous.
4. Ajouter votre logo réel dans `assets/images/` et sur le splash screen
   (`lib/screens/splash_screen.dart`), et configurer l'icône de l'app.
5. Tester sur iOS et Android (`flutter run`).

## 📻 Radio en direct

`api_service.dart` appelle `https://hamanieh-flash.net/api/radio.php?action=stream-url`,
qui doit renvoyer `{"url": "..."}` avec l'URL d'écoute directe de votre
serveur Shoutcast — **pas** un lien WindowsMedia/Winamp/WebPlayer, mais le
flux MP3 brut (type=http), du style :
`http://ecmanager5.pro-fhi.net:2870/;?type=http`

Si ce réglage est vide ou erroné côté back-office, l'appli retombe
automatiquement sur cette même URL codée en dur dans `api_service.dart`
(variable `_fallbackStreamUrl`) et dans `radio_screen.dart`, pour ne jamais
bloquer complètement l'écoute — pensez à la mettre à jour si votre
hébergeur de streaming change.

## 🔔 Notifications push (Firebase)

L'appli est câblée pour Firebase Cloud Messaging (`lib/services/notification_service.dart`),
mais a besoin de votre propre projet Firebase pour fonctionner :

1. Créez un projet sur https://console.firebase.google.com
2. Ajoutez une appli Android avec le package `net.hamaniehflash.hamanieh_flash`
   (celui généré par `flutter create --org net.hamaniehflash .` dans le workflow CI)
3. Téléchargez le fichier `google-services.json` et déposez-le **à la racine
   du dépôt**, à côté de `pubspec.yaml` — le script `patch_manifest.py` le
   copie automatiquement au bon endroit pendant le build et active le
   plugin Gradle nécessaire. Sans ce fichier, l'appli se construit et
   fonctionne quand même, simplement sans notifications push.
4. Toutes les installations de l'appli s'abonnent automatiquement au topic
   FCM `all_users`. Pour envoyer une notification à tout le monde, depuis
   la console Firebase : Engagement → Messaging → Nouvelle campagne →
   ciblez le topic `all_users` (pas besoin de gérer les tokens par appareil).
5. Les notifications reçues sont affichées immédiatement si l'appli est
   ouverte, et conservées dans un historique local (visible dans l'onglet
   Notifications) même après redémarrage du téléphone.

## Écrans ajoutés récemment

- `splash_screen.dart` : écran de démarrage (2 secondes), affiché avant la navigation principale.
- `article_detail_screen.dart` : détail d'un article, ouvert au clic depuis l'Accueil ou les Actualités ; récupère le contenu complet via `article_detail.php`.
