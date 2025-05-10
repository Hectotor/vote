# Fonctions Cloud pour Vote

Ce dossier contient des fonctions Cloud Firebase qui automatisent le processus de nettoyage des ressources lors de la suppression d'un post.

## Fonction `cleanupPostResources`

Cette fonction se du00e9clenche automatiquement lorsqu'un post est supprimu00e9. Elle supprime :

- Les images stocku00e9es dans Firebase Storage
- Les commentaires associu00e9s au post
- Les likes associu00e9s au post
- Les hashtags associu00e9s au post
- Les mentions associu00e9es au post
- Les notifications associu00e9es au post
- Les rapports associu00e9s au post

## Du00e9ploiement

Pour du00e9ployer les fonctions :

```bash
cd functions
npm install
firebase deploy --only functions
```

## Utilisation

Une fois du00e9ployu00e9e, la fonction s'exu00e9cute automatiquement lorsqu'un post est supprimu00e9. 

Vous pouvez du00e9sormais supprimer des posts directement depuis votre application sans vous soucier de nettoyer manuellement toutes les ressources associu00e9es.

## Logs

Vous pouvez consulter les logs de la fonction dans la console Firebase pour vu00e9rifier que tout fonctionne correctement.
