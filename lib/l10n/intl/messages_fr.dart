// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '${count} sélectionnée', other: '${count} sélectionnées')}";

  static String m1(name) => "${name} ajouté aux proxys locaux";

  static String m2(name) => "${name} est déjà dans les proxys locaux";

  static String m3(count, skipped) =>
      "${count} à ajouter, ${skipped} ignorés car déjà présents";

  static String m4(detail) => "Impossible d’effacer les données : ${detail}";

  static String m5(code) =>
      "Windows a refusé d’exécuter FlClashCore.exe (erreur ${code}). Une stratégie de contrôle des applications, telle que Smart App Control ou AppLocker, bloque les programmes non signés ; autorisez FlClash dans cette stratégie ou désactivez-la, puis réessayez.";

  static String m6(name) =>
      "L’app n’a pas réussi à finir de démarrer deux fois de suite. Pour sortir de cette boucle, le profil ${name} a été désélectionné et la configuration automatique a été ignorée. Vous pouvez le sélectionner de nouveau à tout moment.";

  static String m7(url) => "Créer un profil à partir de ${url} ?";

  static String m8(count, label) =>
      "${Intl.plural(count, one: '1 règle SUB-RULE a été abandonnée, car les profils personnalisés ne prennent pas en charge les sous-règles', other: '${label} règles SUB-RULE ont été abandonnées, car les profils personnalisés ne prennent pas en charge les sous-règles')}";

  static String m9(message) =>
      "Le cœur ne peut pas analyser ce proxy : ${message}";

  static String m10(proxy, target) =>
      "${proxy} se connecte via ${target}, qui renvoie à ${proxy} ; la connexion boucle";

  static String m11(name) =>
      "Le nom ${name} est déjà utilisé par un autre proxy ou groupe de proxys";

  static String m12(path) =>
      "Les groupes de proxys se référencent mutuellement en boucle : ${path}";

  static String m13(name) =>
      "Le repli si vide doit être un proxy, mais ${name} n’existe pas ou est un groupe de proxys";

  static String m14(name, message) =>
      "${name} n’est pas une regex valide : ${message}";

  static String m15(name) => "Le proxy de connexion ${name} n’existe pas";

  static String m16(names) =>
      "Ces fournisseurs de proxys n’existent pas : ${names}";

  static String m17(names) =>
      "Ces proxys ou stratégies n’existent pas : ${names}";

  static String m18(name) =>
      "${name} est un nom de stratégie intégré et ne peut pas être utilisé ici";

  static String m19(count) =>
      "${count} éléments posent problème, et l’application de ce profil peut échouer";

  static String m20(count) =>
      "${Intl.plural(count, one: 'il y a 1 jour', other: 'il y a ${count} jours')}";

  static String m21(count) =>
      "${Intl.plural(count, other: 'il y a ${count} j')}";

  static String m22(label) =>
      "Voulez-vous vraiment supprimer les éléments sélectionnés (${label}) ?";

  static String m23(label) =>
      "Voulez-vous vraiment supprimer cet élément (${label}) ?";

  static String m24(label) => "Détails de ${label}";

  static String m25(name) =>
      "La connexion via ${name} renvoie au proxy qui l’utilise ; la connexion a donc été arrêtée";

  static String m26(label) => "${label} ne peut pas être vide";

  static String m27(label) => "${label} existe déjà";

  static String m28(count) => "${count} éléments en échec";

  static String m29(label, message) => "${label} : ${message}";

  static String m30(name) => "${name} est déjà à jour";

  static String m31(name) => "${name} mis à jour";

  static String m32(count) =>
      "${Intl.plural(count, one: '1 groupe', other: '${count} groupes')}";

  static String m33(count) => "${count} expirés";

  static String m34(action) =>
      "Déjà utilisé par « ${action} ». L’enregistrer le déplace ici.";

  static String m35(modifiers) =>
      "Incluez au moins l’une de ces touches : ${modifiers}";

  static String m36(count) =>
      "${Intl.plural(count, one: 'il y a 1 heure', other: 'il y a ${count} heures')}";

  static String m37(count) =>
      "${Intl.plural(count, other: 'il y a ${count} h')}";

  static String m38(target) => "${target} n’est pas une stratégie valide";

  static String m39(proxyName) => "${proxyName} n’est pas un proxy valide";

  static String m40(providerName) =>
      "${providerName} n’est pas un fournisseur de proxys valide";

  static String m41(ruleSet) => "${ruleSet} n’est pas un jeu de règles valide";

  static String m42(subRule) => "${subRule} n’est pas un SUB_RULE valide";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 élément', other: '${count} éléments')}";

  static String m44(line, message) => "Ligne ${line} : ${message}";

  static String m45(appName) =>
      "1. Ouvrez Réglages système > Confidentialité et sécurité\n2. Choisissez Service de localisation\n3. Trouvez ${appName} dans la liste et cochez-le\n\nUne fois terminé, revenez dans l’app pour continuer. Merci de votre coopération.";

  static String m46(label, max) =>
      "${label} ne doit pas dépasser ${max} caractères";

  static String m47(size) => "${size} libérés";

  static String m48(count) =>
      "${Intl.plural(count, one: 'il y a 1 minute', other: 'il y a ${count} minutes')}";

  static String m49(count) =>
      "${Intl.plural(count, other: 'il y a ${count} min')}";

  static String m50(count) =>
      "${Intl.plural(count, one: 'il y a 1 mois', other: 'il y a ${count} mois')}";

  static String m51(count) =>
      "${Intl.plural(count, other: 'il y a ${count} m')}";

  static String m52(code) =>
      "Le serveur a refusé l’accès (HTTP ${code}). Le lien a peut-être expiré, ou les identifiants sont incorrects";

  static String m53(code) => "Le serveur a rejeté la requête (HTTP ${code})";

  static String m54(code) =>
      "Rien n’a été trouvé à cette adresse (HTTP ${code}). Vérifiez que l’URL est correcte";

  static String m55(detail) => "Échec de la requête réseau : ${detail}";

  static String m56(code) =>
      "Le serveur a rencontré un problème (HTTP ${code}). Réessayez plus tard";

  static String m57(label) => "Aucun élément (${label}) pour le moment";

  static String m58(label, min, max) =>
      "${label} doit être compris entre ${min} et ${max}";

  static String m59(label) => "${label} doit être un nombre";

  static String m60(label) => "${label} doit être compris entre 1024 et 49151";

  static String m61(port) => "Port ${port}";

  static String m62(days) =>
      "${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m63(date, days) =>
      "Expire le ${date}, ${Intl.plural(days, one: '1 jour restant', other: '${days} jours restants')}";

  static String m64(time) => "Mis à jour ${time}";

  static String m65(label, profiles) =>
      "${label} est encore utilisé par ${profiles}, qui ne fonctionneront plus correctement s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m66(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxys')}";

  static String m67(name, count) => "${name} et autres (${count} proxys)";

  static String m68(removed) =>
      "Ces proxys seront supprimés : ${removed}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m69(removed, added) =>
      "Ces proxys seront supprimés : ${removed}. Ceux-ci seront ajoutés : ${added}. Une ligne dont le nom a changé compte comme un nouveau proxy, et les profils personnalisés qui nomment les proxys supprimés les signaleront comme manquants. Appliquer quand même ?";

  static String m70(label) =>
      "${label} est encore nommé par des règles, des groupes de proxys, des proxys de connexion, le DNS ou le NTP de ce profil, qui cesseront de fonctionner s’il est supprimé. Voulez-vous vraiment le supprimer ?";

  static String m71(count, label) =>
      "${Intl.plural(count, one: '1 groupe de proxys', other: '${label} groupes de proxys')}";

  static String m72(count, label) =>
      "${Intl.plural(count, one: '1 règle', other: '${label} règles')}";

  static String m73(appName) => "${appName} (mode sans échec)";

  static String m74(count) =>
      "${Intl.plural(count, one: '1 seconde', other: '${count} secondes')}";

  static String m75(count) => "${count} actifs";

  static String m76(count) =>
      "${Intl.plural(count, one: '1 problème', other: '${count} problèmes')}";

  static String m77(time) => "Vérifié à ${time}";

  static String m78(count) =>
      "${Intl.plural(count, one: '1 réglage', other: '${count} réglages')}";

  static String m79(link) => "Aucun proxy n’a pu être lu dans ${link}";

  static String m80(label) => "${label} doit être un seul élément";

  static String m81(value) => "Pic ${value}";

  static String m82(value) => "Total ${value}";

  static String m83(transport) => "En-têtes ${transport}";

  static String m84(label) => "${label} doit être une URL";

  static String m85(count) =>
      "${Intl.plural(count, one: 'il y a 1 an', other: 'il y a ${count} ans')}";

  static String m86(count) =>
      "${Intl.plural(count, other: 'il y a ${count} a')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Contrôle d’accès"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Seules les apps sélectionnées passent par le VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle d’accès choisit les apps qui utilisent le proxy.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle d’accès des apps est désactivé",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Les apps sélectionnées sont exclues du VPN",
    ),
    "accessControlSelectedCount": m0,
    "account": MessageLookupByLibrary.simpleMessage("Compte"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Tester tous les délais",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Mode direct"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Mode global"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Changer de mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Proxy système"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Mode règles"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Démarrer/Arrêter"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour les profils",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Afficher/Masquer"),
    "add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Ajouter un proxy"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Ajouter des filtres"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Ajouter des nœuds"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Ajouter une entrée de remplacement",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Ajouter un profil"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Ajouter un groupe de proxys",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Ajouter une règle"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage(
      "Ajouter un réglage",
    ),
    "addSsid": MessageLookupByLibrary.simpleMessage("Ajouter un SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Ajouter aux proxys locaux",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Règles ajoutées"),
    "addedToLocalProxies": m1,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Paramètres supplémentaires",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Préfixe du nom"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Suffixe du nom"),
    "address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "Adresse du serveur WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une adresse WebDAV valide",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration avancée",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "La configuration avancée regroupe le réseau, le DNS, les règles ajoutées et les scripts.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Profil chiffré",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Clé secrète age"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "Ce profil est chiffré avec age et nécessite une clé secrète age pour être déchiffré",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Accepter"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "Tous les proxys référencés",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Tous les fournisseurs de proxys référencés",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Autoriser les apps à contourner le VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Autoriser le LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("IP autorisées"),
    "alreadyInLocalProxies": m2,
    "answers": MessageLookupByLibrary.simpleMessage("Réponses"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle d’accès des apps",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Conception de l’icône de l’app",
    ),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy local",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Ajouter le DNS du système",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentification"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "L’authentification demande un nom d’utilisateur et un mot de passe sur le port du proxy local.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Le proxy système n’est pas appliqué tant que l’authentification est activée.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Autoriser"),
    "authorized": MessageLookupByLibrary.simpleMessage("Autorisé"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Rechercher les mises à jour automatiquement",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Fermer les connexions automatiquement",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "La fermeture automatique coupe les connexions ouvertes lorsque vous changez de proxy.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage(
      "Inclure automatiquement",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Lancement automatique"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Démarrage automatique"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Le démarrage automatique active le proxy à l’ouverture de l’app.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Définir automatiquement le DNS du système",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage(
      "Mise à jour automatique",
    ),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de mise à jour automatique",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Retour"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage(
      "Flou d’arrière-plan",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Sauvegarde"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Sauvegarde et restauration",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Cette sauvegarde provient d’une version plus récente de l’app. Mettez l’app à jour avant de la restaurer",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Sauvegarde réussie"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Infos de base"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Stratégies de base"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Ajout groupé"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Importation groupée"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "Un lien par ligne",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "Un élément par ligne, ou séparés par des virgules",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "Une entrée par ligne : la clé, un espace, puis la valeur",
    ),
    "batchPreviewTip": m3,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "Une URL par ligne",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Ignorer l’optimisation de la batterie maintient l’app active en arrière-plan.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Lier"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Mode liste noire"),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Bloquer la connexion",
    ),
    "brightness": MessageLookupByLibrary.simpleMessage("Luminosité"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Domaines contournés"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Les domaines contournés ne s’appliquent que si le proxy système est activé.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Contourner les adresses privées",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Avec « Contourner les adresses privées » activé, les adresses LAN, de bouclage et multicast ne passent pas par TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage(
      "Algorithme de cache",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Le cache est corrompu. Le vider ?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Taille du cache"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Autorisez l’accès à l’appareil photo dans les réglages du système pour scanner des codes QR, ou choisissez une image de code QR dans l’album.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de l’appareil photo requise",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Appareil photo indisponible",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Tout désélectionner",
    ),
    "cannotSave": MessageLookupByLibrary.simpleMessage(
      "Enregistrement impossible",
    ),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Échec du changement de proxy ; la sélection précédente a été rétablie",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Changements majeurs",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Nouveautés"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage(
      "Corrections de bugs",
    ),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage(
      "Performances",
    ),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Annulations"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Vérifier les certificats TLS",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Sans vérification TLS, les abonnements et les sauvegardes sont exposés aux attaques de l’homme du milieu.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage(
      "Rechercher des mises à jour",
    ),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "L’app est déjà à jour",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Chiffrement"),
    "clearData": MessageLookupByLibrary.simpleMessage("Effacer les données"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "Cela supprime tous les profils, réglages et données locales, puis ferme l’app. Rouvrez-la pour repartir de zéro.",
    ),
    "clearDataFailed": m4,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("Vider le cache DNS"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "Échec du vidage du cache DNS",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Effacer la recherche"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Empreinte client",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Exporter vers le presse-papiers",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Importer depuis le presse-papiers",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de copier dans le presse-papiers. La sélection est peut-être trop volumineuse",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Fermer"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Fermer les connexions",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Couleur"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Style de couleur"),
    "columns": MessageLookupByLibrary.simpleMessage("Colonnes"),
    "compact": MessageLookupByLibrary.simpleMessage("Compact"),
    "compatible": MessageLookupByLibrary.simpleMessage("Mode de compatibilité"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment effacer toutes les données ?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment supprimer ce groupe de proxys ?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment quitter la fenêtre actuelle ?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment forcer le plantage du cœur ?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Contrôle de congestion",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Contrôle de congestion TCP",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôle de congestion TCP ne fonctionne qu’avec la pile mips.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connecté"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connexion…"),
    "connection": MessageLookupByLibrary.simpleMessage("Connexion"),
    "connectionStats": MessageLookupByLibrary.simpleMessage(
      "Statistiques de connexion",
    ),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Connexions en direct, requêtes récentes et requêtes DNS",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connexions"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivité : "),
    "content": MessageLookupByLibrary.simpleMessage("Contenu"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Le contenu ne peut pas être vide",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Gérer les règles ajoutées globales",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copier les variables d’environnement",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copier le lien"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copié avec succès"),
    "core": MessageLookupByLibrary.simpleMessage("Cœur"),
    "coreBlockedByPolicyTip": m5,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control a bloqué FlClashCore.exe car il n’est pas signé. Ouvrez Sécurité Windows → Contrôle des applications et du navigateur → Paramètres de Smart App Control, choisissez Désactivé, puis relancez FlClash. Smart App Control ne peut pas être réactivé sans réinstaller Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("État du cœur"),
    "country": MessageLookupByLibrary.simpleMessage("Région"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Plantage détecté"),
    "crashDetectedTip": m6,
    "crashTest": MessageLookupByLibrary.simpleMessage("Test de plantage"),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createProfileFromUrlTip": m7,
    "creationTime": MessageLookupByLibrary.simpleMessage("Date de création"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Contient le bouton de démarrage et ne peut pas être retiré",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "customColor": MessageLookupByLibrary.simpleMessage(
      "Couleur personnalisée",
    ),
    "customImportDroppedSubRules": m8,
    "customIssueCoreRejected": m9,
    "customIssueDialerLoop": m10,
    "customIssueDuplicateName": m11,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "Le nom est vide",
    ),
    "customIssueGroupLoop": m12,
    "customIssueInvalidEmptyFallback": m13,
    "customIssueInvalidFilter": m14,
    "customIssueMissingDialer": m15,
    "customIssueMissingProviders": m16,
    "customIssueMissingProxies": m17,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy ni fournisseur de proxys n’est sélectionné ; le cœur rejette donc ce groupe",
    ),
    "customIssueReservedName": m18,
    "customIssuesSummary": m19,
    "customProfile": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Assembler des groupes de proxys et des règles à partir des proxys de l’app et d’autres profils",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Ressources des profils personnalisés",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Les ressources des profils personnalisés sont les proxys, fournisseurs de règles, filtres et jeux d’icônes que vous ajoutez vous-même pour les profils personnalisés.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Couper"),
    "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Tableau de bord"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Disponibles à l’ajout",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Échec de l’enregistrement de la modification ; elle a été annulée",
    ),
    "daysAgo": m20,
    "daysAgoShort": m21,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Sélection par défaut",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Par défaut"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "La configuration doit être un mappage YAML avec un nom et un type",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Délai"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Test de délai"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Délai d’expiration du test de latence",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteMultipTip": m22,
    "deleteTip": m23,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Un client proxy multiplateforme basé sur ClashMeta, simple d’utilisation, open source et sans publicité.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP de destination",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN de l’IP de destination",
    ),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Repose sur une API tierce ; à titre indicatif uniquement",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Mode développeur"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Le mode développeur est activé.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Proxy de connexion"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Le proxy de connexion est la sortie utilisée pour joindre le serveur NTP.",
    ),
    "dialerProxyLoopStopped": m25,
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Désactiver le transfert ICMP",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "Avec le transfert ICMP désactivé, TUN répond lui-même au ping, qui n’indique donc plus la latence réelle.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Désactiver le keep-alive TCP",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Désactiver UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Abandonner les modifications ?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Avertissement"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "En installant, copiant ou utilisant le Logiciel, vous êtes réputé avoir lu et accepté l’intégralité de cette déclaration. Si vous n’êtes pas d’accord avec l’une de ses conditions, cessez immédiatement d’utiliser le Logiciel et désinstallez-le.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage(
      "Acceptation",
    ),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "J\'ai lu et compris cette déclaration",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "Pour confirmer que vous avez compris, lisez la déclaration suivante et cochez la case ci-dessous :",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Confirmer la déclaration",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "Les développeurs peuvent réviser cette déclaration à chaque version, et la révision prend effet à la publication de cette version. Continuer à utiliser le Logiciel après une mise à jour signifie que vous acceptez la déclaration révisée.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Modifications de cette déclaration",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Avant d’utiliser FlClash (« le Logiciel »), veuillez lire attentivement cette déclaration et vous assurer de l’avoir comprise dans son intégralité. Appuyer sur « Accepter » signifie que vous avez lu, compris et accepté chacune des conditions ci-dessous. Si vous n’êtes pas d’accord, appuyez sur « Quitter » et cessez d’utiliser le Logiciel.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "Dans toute la mesure permise par la loi applicable, ni les développeurs ni aucun contributeur ne sauraient être tenus responsables de dommages directs, indirects, accessoires, spéciaux, punitifs ou consécutifs résultant de l’utilisation ou de l’impossibilité d’utiliser le Logiciel, y compris, sans s’y limiter, la perte de données, les dommages matériels, les pannes réseau, l’interruption d’activité, le manque à gagner ou tout litige qui en découlerait, même s’ils ont été avertis de la possibilité de tels dommages.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Limitation de responsabilité",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est open source sous licence GPL-3.0. Vous pouvez l’utiliser, le modifier et le distribuer librement tant que vous respectez cette licence, qui exige que les œuvres dérivées soient elles aussi publiées sous GPL-3.0 et que les mentions de droit d’auteur d’origine soient conservées.\n\nLes composants tiers du Logiciel, dont le cœur Clash.Meta, suivent leurs propres licences. Les auteurs d’origine ne sont pas responsables des problèmes liés aux versions modifiées ou redistribuées.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Licence open source",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel ne fournit lui-même aucun serveur proxy, nœud, abonnement ni service d’accès au réseau, et n’a aucun partenariat, mandat ni lien de garantie avec un quelconque fournisseur de tels services.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel ne collecte ni ne transmet vos URL d’abonnement, détails de nœuds, contenus de configuration, sites visités, historiques de connexion, contenus de trafic ou journaux. Ces données restent sur votre appareil et les développeurs n’y ont pas accès.\n\nLe Logiciel n’accède au réseau que lorsque vous utilisez une fonction qui en a besoin, par exemple pour récupérer l’URL d’abonnement que vous avez fournie lors de la mise à jour d’un profil, ou pour contacter GitHub lors de la recherche de mises à jour.\n\nLe Logiciel n’inclut aucun service d’analyse ni de rapport de plantage, sur aucune plateforme.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Collecte de données et confidentialité",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "Il vous incombe de vous assurer que l’utilisation du Logiciel est licite là où vous vivez, et vous assumez seul la responsabilité juridique de tout ce que vous faites avec lui et de ses conséquences.\n\nLes abonnements, nœuds et configurations que vous importez relèvent de votre choix. La licéité de leur source, la sécurité de leur contenu et la fiabilité de leur service sont une affaire entre vous et leurs fournisseurs.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Votre responsabilité",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Saisissez la déclaration ci-dessus",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Ne correspond pas à la déclaration",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "Pour confirmer que vous avez compris, saisissez la déclaration suivante en entier dans le champ ci-dessous :",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Recopier la déclaration",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est un client proxy réseau open source construit sur le cœur Clash.Meta (mihomo). Il se limite à fournir des outils locaux tels que la gestion de la configuration, le routage par règles et le transfert du trafic.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Nature du logiciel",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Les liens d’abonnement, fichiers de configuration, jeux de règles, scripts, ressources externes et liens externes sont tous fournis par des tiers. Les développeurs ne peuvent ni ne vont vérifier ou garantir leur légalité, leur exactitude, leur sécurité ou leur disponibilité.\n\nTout vol de données, perte financière, bannissement de compte ou autre dommage causé par un contenu tiers se règle entre vous et le tiers concerné ; les développeurs n’en assument aucune responsabilité.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Contenus tiers",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est destiné uniquement à des usages non commerciaux tels que l’apprentissage, les échanges et la recherche technique. Toute utilisation à des fins commerciales est strictement interdite, y compris, sans s’y limiter, la distribution payante, la vente groupée, l’intégration à un service commercial ou l’exercice d’une activité au nom du Logiciel. Toute activité commerciale est étrangère au Logiciel et à ses développeurs.\n\nIl est strictement interdit d’utiliser le Logiciel à des fins contraires aux lois et règlements de votre pays ou de votre région, y compris, sans s’y limiter, le contournement de restrictions d’accès au réseau légalement imposées, la diffusion de contenus illicites, le lancement d’attaques réseau ou l’atteinte aux droits légitimes d’autrui.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Restrictions d’utilisation",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "Le Logiciel est fourni « tel quel » et « selon disponibilité », sans garantie d’aucune sorte, expresse ou implicite, y compris, sans s’y limiter, les garanties de qualité marchande, d’adéquation à un usage particulier, d’absence de contrefaçon, de disponibilité ininterrompue, d’absence d’erreurs ou d’absence de failles de sécurité.\n\nLes développeurs ne garantissent pas que le Logiciel répondra à vos besoins ni qu’il fonctionnera sans interruption ni erreur.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "Absence de garantie",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Déconnecté"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Nouvelle version disponible",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("Cache DNS vidé"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Sans cette entrée, TUN détourne toutes les requêtes DNS vers le port 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Détournement DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Mode DNS"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent le DNS de tous les profils URL et fichier ; tout ce qui n’est pas ajouté garde le réglage du profil. Les profils personnalisés définissent leur DNS dans leur contenu.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("Requêtes DNS"),
    "docked": MessageLookupByLibrary.simpleMessage("Ancrée"),
    "domain": MessageLookupByLibrary.simpleMessage("Domaine"),
    "done": MessageLookupByLibrary.simpleMessage("Terminé"),
    "download": MessageLookupByLibrary.simpleMessage("Réception"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Bande passante de réception",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Durée"),
    "edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "editDashboard": MessageLookupByLibrary.simpleMessage(
      "Modifier le tableau de bord",
    ),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Modifier les règles globales",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Modifier le proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Modifier le groupe de proxys",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Modifier la règle"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Modifier le SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Éditeur indisponible",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Durée"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Repli si vide"),
    "emptyTip": m26,
    "en": MessageLookupByLibrary.simpleMessage("Anglais"),
    "enabled": MessageLookupByLibrary.simpleMessage("Activé"),
    "entries": MessageLookupByLibrary.simpleMessage(" entrées"),
    "error": MessageLookupByLibrary.simpleMessage("Erreur"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Détails de l’erreur"),
    "es": MessageLookupByLibrary.simpleMessage("Espagnol"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "Masquer des tâches récentes",
    ),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Ports de destination exclus",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic vers les ports de destination exclus ne passe pas par TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Filtre d’exclusion"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces exclues",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic qui arrive sur les interfaces exclues, par exemple docker0, ne passe pas par TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Ports source exclus",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic issu des ports source exclus ne passe pas par TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("SSID exclus"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "Lorsque vous êtes connecté à un Wi-Fi dont le SSID est exclu, l’état d’exécution de l’app change automatiquement.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("ID utilisateur exclus"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Le trafic des processus des ID utilisateur exclus ne passe pas par TUN.",
    ),
    "existsTip": m27,
    "exit": MessageLookupByLibrary.simpleMessage("Quitter"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Quitter le plein écran",
    ),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Nœuds de sortie"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Statut attendu"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Date d’expiration"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Exporter le fichier"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Exporter les journaux"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportation réussie",
    ),
    "extend": MessageLookupByLibrary.simpleMessage("Extension"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Mode d’extension"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Script d’extension"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Contrôleur externe",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Le contrôleur externe permet de piloter le cœur via le port 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "Secret du contrôleur externe",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Lien externe"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Très grande"),
    "fade": MessageLookupByLibrary.simpleMessage("Fondu"),
    "failedCount": m28,
    "failedItem": m29,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Filtre Fake-IP"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Mode du filtre Fake-IP",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "En mode filtre Fake-IP, la liste noire exclut les correspondances, la liste blanche ne falsifie que les correspondances, et « rule » les traite comme des règles.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Plage Fake-IP"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Plage Fake-IP (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("TTL Fake-IP"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Filtre de repli"),
    "file": MessageLookupByLibrary.simpleMessage("Fichier"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Importer directement un fichier de profil",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Le fichier a été modifié. Enregistrer les modifications ?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtres"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage(
      "Recherche de processus",
    ),
    "floating": MessageLookupByLibrary.simpleMessage("Flottante"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Suivre le profil"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Suivre le système"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Police"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Taille"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Forcer le mappage DNS",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Forcer le mappage DNS analyse aussi les connexions dont le domaine provient d’un mappage DNS.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Domaines forcés"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Les domaines forcés sont aussi analysés ; les autres connexions qui ont déjà un domaine sont laissées telles quelles.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment forcer le redémarrage du cœur ?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("Français"),
    "general": MessageLookupByLibrary.simpleMessage("Général"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Mode Geo à faible mémoire",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Aller"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Télécharger"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Aller à la configuration des règles ajoutées",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Aller à la configuration du script",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Grille"),
    "groupCount": m32,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groupes"),
    "groupTimeoutCount": m33,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Mettre les modifications en cache ?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Hachage par utilisateur entrant",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Contrôle d’état"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Service Helper indisponible ; le mode TUN ne peut pas être activé. Réinstallez FlClash pour le rétablir.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Masquer de la liste"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Masquer l’IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage(
      "Masquer le mot de passe",
    ),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Masquer les proxys expirés",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Intervalle de saut"),
    "host": MessageLookupByLibrary.simpleMessage("Hôte"),
    "hostname": MessageLookupByLibrary.simpleMessage("Nom d’hôte"),
    "hotkeyConflictWith": m34,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Les raccourcis globaux fonctionnent même lorsque la fenêtre est masquée. Appuyez sur une action pour enregistrer sa combinaison de touches.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Gestion des raccourcis",
    ),
    "hotkeyNeedsModifier": m35,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Non défini"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Non enregistré, il est peut-être pris par une autre app",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("heures"),
    "hoursAgo": m36,
    "hoursAgoShort": m37,
    "hue": MessageLookupByLibrary.simpleMessage("Teinte"),
    "icon": MessageLookupByLibrary.simpleMessage("Icône"),
    "iconRecords": MessageLookupByLibrary.simpleMessage(
      "Historique des icônes",
    ),
    "iconSets": MessageLookupByLibrary.simpleMessage("Jeux d’icônes"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Aucun jeu d’icônes pour le moment. Ajoutez-en dans Ressources des profils personnalisés → Jeux d’icônes",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Style des icônes"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Pleines"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Masquées"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Simples"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL de l’icône"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignorer l’optimisation de la batterie",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importer"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "Ce fichier n’est pas une configuration importable",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "L’importation remplace les groupes de proxys, les règles et les réglages actuels de ce profil",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage(
      "Importer depuis un fichier",
    ),
    "importFromLink": MessageLookupByLibrary.simpleMessage(
      "Importer depuis un lien",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage(
      "Importer depuis une URL",
    ),
    "inbound": MessageLookupByLibrary.simpleMessage("Entrant"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Interfaces incluses",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Seul le trafic arrivant sur les interfaces incluses passe par TUN, et les interfaces exclues ne s’appliquent plus.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("ID utilisateur inclus"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Seul le trafic des processus des ID utilisateur inclus passe par TUN.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("N’expire jamais"),
    "init": MessageLookupByLibrary.simpleMessage("Initialisation"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Échec du démarrage"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "FlClash a rencontré une erreur au démarrage et ne peut pas continuer. Copiez les détails pour signaler le problème. Si cela se reproduit, effacer les données permet généralement de relancer l’app.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Initiateur"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("De"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Saisissez le nom du groupe de proxys",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez le contenu de la règle",
    ),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "L’autorisation de la liste des apps a été refusée ; les apps installées ne peuvent donc pas être listées. Veuillez l’accorder manuellement dans les réglages du système.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Ce système masque la liste des apps installées tant que l’autorisation n’est pas accordée. Accordez-la pour configurer le proxy par app.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de la liste des apps requise",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage(
      "Polices installées",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Sélection intelligente",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Nom de l’interface"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Le nom de l’interface est l’interface réseau utilisée par les connexions sortantes.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Interface sortante",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Aucune"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage(
      "Personnalisée",
    ),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Suivre la configuration",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Intervalle"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP du réseau local"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Fichier de sauvegarde non valide",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez une plage d’IP au format CIDR, par exemple 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "Une marque DSCP ne peut pas dépasser 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez un domaine ou une adresse IP",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Jeu d’icônes non valide",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Ce n’est ni un lien d’abonnement ni un lien de partage de proxy",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez une adresse et un port, par exemple 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Seuls tcp ou udp sont pris en charge",
    ),
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez un port ou une plage, par exemple 443 ou 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Ce code QR ne contient pas de lien de profil",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Saisissez des nombres ou des plages tels que 80 ou 8000-9000, séparés par /",
    ),
    "invalidRuleSet": m41,
    "invalidSubRule": m42,
    "ipAddress": MessageLookupByLibrary.simpleMessage("Adresse IP"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Antécédents d’abus"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Indicateurs"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organisation"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de déterminer le type de l’IP",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Bonne"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Niveau"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normale"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage(
      "Vérifier à nouveau",
    ),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("À risque"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Qualité"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Réponse de"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Sources"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "IP sortante différente",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Aucun type"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Limite de débit atteinte",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Type"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Entreprise"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Centre de données"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Réseau mobile"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Résidentielle"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Type inconnu"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("Version d’IP"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Le trafic IPv6 n’est reçu que si IPv6 est activé.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Avec IPv6 activé, le VPN autorise le trafic IPv6 entrant.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage(
      "Délai d’expiration IPv6 (ms)",
    ),
    "itemsCount": m43,
    "ja": MessageLookupByLibrary.simpleMessage("Japonais"),
    "justNow": MessageLookupByLibrary.simpleMessage("À l’instant"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "Inactivité keep-alive TCP",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Intervalle keep-alive TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Clé"),
    "ko": MessageLookupByLibrary.simpleMessage("Coréen"),
    "label": MessageLookupByLibrary.simpleMessage("Libellé"),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "large": MessageLookupByLibrary.simpleMessage("Grande"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Dernière mise à jour"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Démarrage inachevé",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "L’app s’est arrêtée de façon inattendue lors de son dernier démarrage. La configuration automatique a été ignorée pour ce lancement ; vous pouvez la démarrer manuellement pour réessayer.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Disposition"),
    "light": MessageLookupByLibrary.simpleMessage("Clair"),
    "lineIssueTip": m44,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Retour à la ligne"),
    "link": MessageLookupByLibrary.simpleMessage("Lien"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Obtenir un profil depuis un lien d’abonnement ou un lien de partage de proxy",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("Liste"),
    "listen": MessageLookupByLibrary.simpleMessage("Écoute"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Marque de routage d’écoute",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "La marque de routage d’écoute ne fonctionne que sous Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage(
      "Connexions en direct",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Chargement…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localImage": MessageLookupByLibrary.simpleMessage("Image locale"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Autorisation du réseau local refusée : la pile gvisor est utilisée, le LAN est inaccessible.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Proxys locaux"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Autorisation de localisation",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "L’autorisation de localisation a été refusée ; le nom du Wi-Fi actuel ne peut donc pas être lu. Veuillez l’activer manuellement dans les réglages du système.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Le système exige l’autorisation de localisation pour lire le nom du Wi-Fi. Sur Android, choisissez « Toujours autoriser », sinon le nom du Wi-Fi ne peut pas être lu lorsque l’app est en arrière-plan.",
    ),
    "locationPermissionGuide": m45,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de localisation requise",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Journal"),
    "logLevel": MessageLookupByLibrary.simpleMessage(
      "Niveau de journalisation",
    ),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Désactiver Logcat masque l’entrée Journaux.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Journaux"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Journaux et diagnostic",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Test des journaux"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Exemption de bouclage UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Aérée"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Respecter la casse"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Faire correspondre l’IP source",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Échecs maximum"),
    "maxLengthTip": m46,
    "maximize": MessageLookupByLibrary.simpleMessage("Agrandir"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Mémoire résidente",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App et partagée"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Tas inactif"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Tas utilisé"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Le cœur n’est pas en cours d’exécution",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Surcharge du runtime",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage(
      "Piles de goroutines",
    ),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimation d’après la mémoire résidente du processus ; elle peut différer de ce qu’indique le système.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Le cœur s’exécute dans le processus de l’app. Sa part est estimée à partir des statistiques du runtime, et le reste compte comme mémoire de l’app et partagée.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Infos mémoire"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Mémoire utilisée par l’app et le cœur",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Mémoire libérée"),
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("Test de message"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Ceci est un message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Réduire"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Réduire à la fermeture",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Port mixte"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Icône monochrome"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("Plus"),
    "name": MessageLookupByLibrary.simpleMessage("Nom"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage(
      "Barre inférieure",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Réseau"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "La requête a été annulée",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Impossible de se connecter au serveur. Vérifiez votre connexion réseau ou vos réglages de proxy",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Impossible de résoudre l’adresse du serveur. Vérifiez que l’URL est correcte et que le DNS fonctionne",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Nom du réseau"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Trop de requêtes (HTTP 429). Patientez un instant puis réessayez",
    ),
    "networkRequestFailed": m55,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Secret du réseau"),
    "networkServerError": m56,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Débit réseau"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage(
      "Prise en charge du trafic",
    ),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "La requête a expiré. Vérifiez votre réseau ou votre proxy, puis réessayez",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Échec de la connexion sécurisée. Le certificat du serveur est peut-être invalide, ou la connexion est interceptée",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Type de réseau"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Résultat suivant"),
    "no": MessageLookupByLibrary.simpleMessage("Non"),
    "noData": MessageLookupByLibrary.simpleMessage("Aucune donnée"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Aucune information"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Ne plus me le rappeler",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Aucun réseau"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Apps sans réseau"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Ne pas résoudre l’IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Ne pas résoudre le nom d’hôte",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("Aucun résultat"),
    "nodes": MessageLookupByLibrary.simpleMessage("Nœuds"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "Cette ressource externe n’est pas un fichier texte",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Aucun"),
    "notRunning": MessageLookupByLibrary.simpleMessage("À l’arrêt"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Le groupe de proxys actuel n’est pas sélectionnable",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de synchronisation (minutes)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP récupère l’heure auprès d’un serveur NTP au lieu de l’horloge système.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Ajoutez un profil pour commencer",
    ),
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuscation"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Hôte d’obfuscation"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Mode d’obfuscation"),
    "obfsParam": MessageLookupByLibrary.simpleMessage(
      "Paramètre d’obfuscation",
    ),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe d’obfuscation",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("À la demande"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "À la demande met le proxy en pause sur les Wi-Fi exclus.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Ne compter que le trafic proxy",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Facultatif"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Autre"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Autres contributeurs",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Sortant"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Sortie"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("IP sortante"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Mode sortant"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Remplacer la destination",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Remplacer la destination se connecte au domaine détecté plutôt qu’à l’adresse d’origine.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage(
      "Entrées de remplacement",
    ),
    "parsePureIp": MessageLookupByLibrary.simpleMessage(
      "Analyser les IP seules",
    ),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Analyser les IP seules inspecte les connexions qui ne portent qu’une adresse IP.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "paste": MessageLookupByLibrary.simpleMessage("Coller"),
    "peers": MessageLookupByLibrary.simpleMessage("Pairs"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage(
      "Choisir dans l’album",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Épingler la fenêtre"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Veuillez lier un WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un nom de script",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Veuillez importer un code QR valide",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage(
      "Chiffrement du plugin",
    ),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Hôte du plugin"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Mode du plugin"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe du plugin",
    ),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Chemin du plugin"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage(
      "Nom d’utilisateur du plugin",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un autre port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Saut de port"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Clé prépartagée"),
    "preferred": MessageLookupByLibrary.simpleMessage("Préféré"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prérequis"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Appuyez sur une combinaison de touches",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Aperçu"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Résultat précédent"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Clé privée"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Phrase secrète de la clé privée",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Processus"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Veuillez saisir un intervalle valide",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Veuillez saisir l’intervalle de mise à jour automatique",
        ),
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Le profil a été modifié. Désactiver la mise à jour automatique ?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le nom du profil",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "S’applique uniquement à ce profil ; tout ce qui n’est pas ajouté utilise la valeur par défaut.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "S’applique uniquement à ce profil et prime sur les entrées de remplacement TUN des réglages réseau.",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une URL de profil valide",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir l’URL du profil",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profils"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Trier les profils"),
    "project": MessageLookupByLibrary.simpleMessage("Projet"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protocole"),
    "protocolParam": MessageLookupByLibrary.simpleMessage(
      "Paramètre du protocole",
    ),
    "protocolVersion": MessageLookupByLibrary.simpleMessage(
      "Version du protocole",
    ),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Seuls les fournisseurs distants sont pris en charge",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Ressources externes"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxys"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Chaîne de proxys"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Groupe de proxys"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Le groupe de proxys est vide",
    ),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Les groupes s’affichent ici une fois le cœur démarré",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "Fournisseurs de proxys",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Type de proxy"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Nettoyer le cache"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Clé publique"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Noir pur"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Mode noir pur"),
    "qrcode": MessageLookupByLibrary.simpleMessage("Code QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scannez un code QR pour obtenir un profil",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "Ce lien est trop long pour un code QR. Utilisez Copier le lien.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Actions rapides"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Modification rapide"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Requêtes récentes"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Suggestions"),
    "recordType": MessageLookupByLibrary.simpleMessage("Type d’enregistrement"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Port Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Rétablir"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Libérer la mémoire"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la libération de la mémoire",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Distant"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Destination distante",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Résolution DNS distante",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Retirer"),
    "rename": MessageLookupByLibrary.simpleMessage("Renommer"),
    "replace": MessageLookupByLibrary.simpleMessage("Remplacer"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Tout remplacer"),
    "request": MessageLookupByLibrary.simpleMessage("Requête"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage(
      "En-têtes de requête",
    ),
    "requests": MessageLookupByLibrary.simpleMessage("Requêtes"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requêtes et mises à jour",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Obligatoire"),
    "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "Cette page contient des modifications. Voulez-vous vraiment réinitialiser ?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment réinitialiser ?",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Intervalle de mise à jour automatique",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "L’intervalle de mise à jour automatique doit être supérieur à 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ressources"),
    "respectRules": MessageLookupByLibrary.simpleMessage(
      "Respecter les règles",
    ),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respecter les règles fait passer les connexions DNS selon les règles et nécessite un Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Code de réponse"),
    "restart": MessageLookupByLibrary.simpleMessage("Redémarrer"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment redémarrer le cœur ?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restaurer"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Restaurer toutes les données",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restaurer uniquement les profils",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Stratégie de restauration",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Écraser"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restauration réussie",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Résultat"),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Adresses de route"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses de route exclues",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Marque de routage"),
    "ru": MessageLookupByLibrary.simpleMessage("Russe"),
    "rule": MessageLookupByLibrary.simpleMessage("Règle"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique ET",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au domaine complet",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à un mot-clé de domaine",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une regex de domaine",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à un suffixe de domaine",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspondance par caractères génériques ; seuls * et ? sont pris en charge",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la marque DSCP (entrant UDP tproxy uniquement)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la plage de ports de destination",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au code pays de l’IP",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond aux domaines de Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom entrant",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au port entrant",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au type entrant",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom d’utilisateur entrant ; séparez plusieurs noms par /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ASN de l’IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP ; IP-CIDR6 n’est qu’un alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage de suffixes d’IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à toutes les requêtes, sans condition",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à TCP ou UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique NON",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Règle logique OU",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom du processus ; correspond au nom du paquet sur Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par regex au nom du processus ; correspond au nom du paquet sur Android",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par caractères génériques au nom du processus ; seuls * et ? sont pris en charge",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au chemin complet du processus",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par regex au chemin du processus",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond par caractères génériques au chemin du processus ; seuls * et ? sont pris en charge",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au nom de rematch ; séparez plusieurs noms par /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Référence un jeu de règles ; nécessite rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond au code pays de l’IP source",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ASN de l’IP source",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage d’adresses IP source",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à une plage de suffixes d’IP source",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à la plage de ports source",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond vers une sous-règle ; attention aux parenthèses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Correspond à l’ID d’utilisateur Linux",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("La règle est vide"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "Les règles doivent former une liste YAML avec une règle par élément, par exemple - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent en direct",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Bloquer DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Bloquer le bouclage du proxy",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("Bloquer QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("Bloquer STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage(
      "LAN en direct",
    ),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple et Microsoft en direct",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "Fournisseurs de règles",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Jeu de règles"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "Le jeu de règles ne contient aucune entrée exploitable",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Ce fichier mrs est illisible",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "Le jeu de règles mélange des domaines et des plages d’IP : son type est indéterminable",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Cible de la règle"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "La règle doit commencer par un type pris en charge, par exemple DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Règles"),
    "rulesCount": m72,
    "runTime": MessageLookupByLibrary.simpleMessage("Durée d’exécution"),
    "running": MessageLookupByLibrary.simpleMessage("En cours d’exécution"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Configuration d’exécution",
    ),
    "safeMode": MessageLookupByLibrary.simpleMessage("Mode sans échec"),
    "safeModeAppTitle": m73,
    "saturation": MessageLookupByLibrary.simpleMessage("Saturation"),
    "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les modifications ?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Mode script : réécrit tout le profil avec un script d’extension",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Défiler jusqu’à la sélection",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "seconds": MessageLookupByLibrary.simpleMessage("secondes"),
    "secondsCount": m74,
    "secretKey": MessageLookupByLibrary.simpleMessage("Clé"),
    "sectionsInEffect": m75,
    "select": MessageLookupByLibrary.simpleMessage("Sélectionner"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un jeu de règles",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une stratégie de répartition",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Envoyer"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage(
      "Envoyer depuis le téléphone",
    ),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Importer le lien envoyé depuis le téléphone ?",
    ),
    "sendFromPhoneDesc": MessageLookupByLibrary.simpleMessage(
      "Scannez avec votre téléphone pour envoyer un lien à cet appareil",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Cet appareil n\'est connecté à aucun réseau local",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Lien d\'abonnement ou lien de partage de proxy",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Envoyé. Confirmez l\'importation sur l\'autre appareil.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "Envoyer un lien à FlClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Pour recevoir un lien depuis le téléphone, FlClash a besoin de l\'autorisation Appareils à proximité, qui lui donne accès au réseau local. Activez-la dans les paramètres de l\'application.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Scannez le code avec l\'appareil photo du téléphone, puis collez le lien dans la page qui s\'ouvre. Les deux appareils doivent être sur le même réseau.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Serveur"),
    "serviceAbnormalCount": m76,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "Tout est disponible",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Disponible"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Bloqué"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Tout vérifier"),
    "serviceCheckedAt": m77,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage(
      "Bientôt disponible",
    ),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "FAI non autorisé",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la vérification",
    ),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Gérer les services"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Contenus originaux uniquement",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Non vérifié"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Accès restreint",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Affiché sur le tableau de bord",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("État des services"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Indisponible"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Région non prise en charge",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("réglages"),
    "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "settingsCount": m78,
    "shareLinkUnreadable": m79,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "Aucun proxy n’a pu être lu dans les liens",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Scannez avec FlClash sur un autre appareil pour importer ce profil.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Afficher"),
    "showLess": MessageLookupByLibrary.simpleMessage("Réduire"),
    "showMore": MessageLookupByLibrary.simpleMessage("Développer"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Bouton Arrêter dans la notification",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage(
      "Afficher le mot de passe",
    ),
    "sidebar": MessageLookupByLibrary.simpleMessage("Barre latérale"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Le flou d’arrière-plan laisse voir le bureau derrière la fenêtre à travers la barre latérale.",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage(
      "Lancement silencieux",
    ),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Le lancement silencieux démarre l’app sans afficher la fenêtre.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Ajout unique"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Importation unique"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Saisissez un seul lien ici ; pour en modifier plusieurs, utilisez la modification rapide de la liste",
    ),
    "singleValueTip": m80,
    "size": MessageLookupByLibrary.simpleMessage("Taille"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Ignorer la vérification du certificat",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Domaines ignorés"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Un domaine détecté figurant dans la liste des domaines ignorés n’est pas utilisé.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses de destination ignorées",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Adresses sources ignorées",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Glissement"),
    "sliders": MessageLookupByLibrary.simpleMessage("Curseurs"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protocoles"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Le sniffer lit le domaine dans le trafic TLS, HTTP et QUIC afin que les règles puissent le reconnaître.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Port SOCKS"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Doux"),
    "sort": MessageLookupByLibrary.simpleMessage("Trier"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP source"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Proxy spécial"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Règles spéciales"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spectre"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Statistiques de débit",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Stratégie de répartition",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "La stratégie de répartition ne peut pas être vide",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("Les SSID sont vides"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Mode de pile"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Trace de pile"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Mode standard : ajoute des règles par-dessus le profil",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Démarrer"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("Partir de zéro"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Démarrage du VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Démarrage et arrière-plan",
    ),
    "status": MessageLookupByLibrary.simpleMessage("État"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Si DNS est désactivé, le DNS du système est utilisé.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Arrêter"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Arrêt du VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Stratégie"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Route stricte"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "La route stricte empêche le trafic tel que le DNS de contourner TUN et, avec IPv6 désactivé, bloque les connexions IPv6 de cet appareil.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "submit": MessageLookupByLibrary.simpleMessage("Valider"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Infos d’abonnement",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Saisissez votre mot de passe pour sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspendu…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Changer de profil"),
    "sync": MessageLookupByLibrary.simpleMessage("Synchroniser"),
    "system": MessageLookupByLibrary.simpleMessage("Système"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Apps système"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Proxy système"),
    "tab": MessageLookupByLibrary.simpleMessage("Onglet"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage(
      "Animation des onglets",
    ),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Appuyez sur l’icône pour réessayer",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour autoriser",
    ),
    "target": MessageLookupByLibrary.simpleMessage("Cible"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP simultané"),
    "testInterval": MessageLookupByLibrary.simpleMessage("Intervalle de test"),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL de test"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Tester à l’utilisation",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Taille du texte"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Le texte de l’app ressemblera à ceci",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Thème"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Couleur du thème"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Mode du thème"),
    "tight": MessageLookupByLibrary.simpleMessage("Serrée"),
    "time": MessageLookupByLibrary.simpleMessage("Heure"),
    "timeout": MessageLookupByLibrary.simpleMessage("Expiré"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Teinté"),
    "tip": MessageLookupByLibrary.simpleMessage("Astuce"),
    "toggle": MessageLookupByLibrary.simpleMessage("Basculer"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolérance"),
    "tools": MessageLookupByLibrary.simpleMessage("Outils"),
    "torch": MessageLookupByLibrary.simpleMessage("Lampe torche"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Reçu"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Trafic total"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Envoyé"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Port TProxy"),
    "traffic": MessageLookupByLibrary.simpleMessage("Trafic"),
    "trafficPeak": m81,
    "trafficTotal": m82,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Trafic utilisé"),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportHeaders": m83,
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN n’a pas pu être autorisé et a donc été désactivé.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN ne fonctionne qu’en mode administrateur.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Les entrées ajoutées ici remplacent les réglages TUN de tous les profils ; tout ce qui n’est pas ajouté garde le réglage du profil. Les entrées qu’un profil personnalisé ajoute lui-même priment.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Désactiver"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Activer"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("Mode de relais UDP"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("Délai UDP"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Le délai UDP est en secondes et ne fonctionne qu’avec les piles gvisor, system et mixed.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Annuler"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Délai unifié"),
    "unknown": MessageLookupByLibrary.simpleMessage("Inconnu"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Erreur réseau inconnue",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restaurer"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Sans nom"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage(
      "Désépingler la fenêtre",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Mettre à jour"),
    "upload": MessageLookupByLibrary.simpleMessage("Envoi"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Bande passante d’envoi",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m84,
    "useHosts": MessageLookupByLibrary.simpleMessage("Utiliser hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Utiliser les hosts du système",
    ),
    "usedShort": MessageLookupByLibrary.simpleMessage("utilisé"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Trafic utilisé"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Nom d’utilisateur"),
    "value": MessageLookupByLibrary.simpleMessage("Valeur"),
    "view": MessageLookupByLibrary.simpleMessage("Afficher"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("IPv4 virtuelle"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Vif"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Modification de la configuration liée au VPN détectée",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Le VPN fait passer automatiquement tout le trafic du système par VpnService.",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuration WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Mode liste blanche"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système",
    ),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Écrire dans le système règle aussi l’horloge système ; Android l’ignore.",
    ),
    "yearsAgo": m85,
    "yearsAgoShort": m86,
    "yes": MessageLookupByLibrary.simpleMessage("Oui"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Chinois simplifié"),
  };
}
