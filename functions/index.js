const { initializeApp, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { onDocumentDeleted } = require('firebase-functions/v2/firestore');
const deletePost = require('./delete_post');

if (!getApps().length) {
  initializeApp();
}

/**
 * Fonction qui s'exécute lorsqu'un post est supprimé
 * Supprime automatiquement toutes les ressources liées à ce post
 * Voir delete_post.js pour les détails d'implémentation
 */
exports.cleanupPostResources = onDocumentDeleted('posts/{postId}', async (event) => {
  const postId = event.params.postId;
  const postData = event.data.before.data();
  
  // Appel de la fonction de nettoyage définie dans delete_post.js
  await deletePost.cleanupPostResources(postId, postData);
  return null;
});
