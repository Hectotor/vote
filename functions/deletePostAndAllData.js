const admin = require("firebase-admin");

/**
 * Supprime un post et toutes ses données liées (Firestore + Storage)
 * @param {string} postId - L'ID du post à supprimer
 * @param {string} userId - L'ID de l'utilisateur (doit être le propriétaire)
 * @returns {Promise<{success: boolean}>}
 */
module.exports = async function deletePostAndAllData(postId, userId) {
  if (!postId || !userId) throw new Error("Arguments manquants");

  // Récupérer le post
  const postRef = admin.firestore().collection('posts').doc(postId);
  const postSnap = await postRef.get();
  if (!postSnap.exists) throw new Error("Post introuvable");
  const postData = postSnap.data();

  // Vérifier que l'utilisateur est bien le propriétaire
  if (postData.userId !== userId) throw new Error("Non autorisé");

  // Supprimer les sous-collections et documents liés
  const collectionsToDelete = [
    'commentLikes', 'commentsPosts', 'followers', 'hashtags',
    'likes', 'mentions', 'notifications', 'reportedPosts',
    'savedPosts', 'votesPosts'
  ];
  for (const col of collectionsToDelete) {
    const snap = await admin.firestore().collection(col).where('postId', '==', postId).get();
    const batch = admin.firestore().batch();
    snap.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
  }

  // Supprimer les images du Storage associées au post
  const { Storage } = require('@google-cloud/storage');
  const storage = new Storage();
  const bucket = storage.bucket(admin.storage().bucket().name);
  if (postData.blocs && Array.isArray(postData.blocs)) {
    for (const bloc of postData.blocs) {
      if (bloc.postImageUrl) {
        try {
          await bucket.file(bloc.postImageUrl).delete();
        } catch (e) {
          // Ignore les erreurs si le fichier n'existe pas
        }
      }
    }
  }

  // Supprimer le post lui-même
  await postRef.delete();

  return { success: true };
};
