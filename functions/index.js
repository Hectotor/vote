const { initializeApp, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { onDocumentDeleted } = require('firebase-functions/v2/firestore');
const { https } = require('firebase-functions/v2');
const deletePost = require('./delete_post');
const { vote } = require('./vote_new');

if (!getApps().length) {
  initializeApp();
}

const db = getFirestore();

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

// Exporter la nouvelle fonction de vote
exports.vote = vote;
