const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Cloud Function pour supprimer un post et toutes les données associées
exports.deletePostAndAllData = functions.https.onCall(async (data, context) => {
  const { postId } = data;
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  // Vérifier que l'utilisateur est bien l'auteur du post
  const postRef = admin.firestore().collection('posts').doc(postId);
  const postSnap = await postRef.get();
  if (!postSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Post not found.');
  }
  if (postSnap.data().userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Not the post owner.');
  }

  // Préparer le batch
  const batch = admin.firestore().batch();

  // 1. Supprimer tous les commentaires du post
  const commentsQuery = await admin.firestore().collection('commentsPosts').where('postId', '==', postId).get();
  commentsQuery.forEach(doc => batch.delete(doc.ref));

  // 2. Supprimer tous les likes sur le post
  const likesQuery = await admin.firestore().collection('likes').where('postId', '==', postId).get();
  likesQuery.forEach(doc => batch.delete(doc.ref));

  // 3. Supprimer tous les likes sur les commentaires du post (optimisé avec postId)
  const commentLikesQuery = await admin.firestore().collection('commentLikes').where('postId', '==', postId).get();
  commentLikesQuery.forEach(doc => batch.delete(doc.ref));

  // 4. Supprimer les votes liés au post
  const votesQuery = await admin.firestore().collection('votesPosts').where('postId', '==', postId).get();
  votesQuery.forEach(doc => batch.delete(doc.ref));

  // 5. Supprimer les notifications liées au post
  const notifQuery = await admin.firestore().collection('notifications').where('postId', '==', postId).get();
  notifQuery.forEach(doc => batch.delete(doc.ref));

  // 6. Supprimer les sauvegardes du post
  const savedQuery = await admin.firestore().collection('savedPosts').where('postId', '==', postId).get();
  savedQuery.forEach(doc => batch.delete(doc.ref));

  // 8. Supprimer les hashtags liés au post (si applicable)
  const hashtagsQuery = await admin.firestore().collection('hashtags').where('postId', '==', postId).get();
  hashtagsQuery.forEach(doc => batch.delete(doc.ref));

  // 9. Supprimer les mentions liées au post (si applicable)
  const mentionsQuery = await admin.firestore().collection('mentions').where('postId', '==', postId).get();
  mentionsQuery.forEach(doc => batch.delete(doc.ref));

  // 10. Supprimer le post lui-même
  batch.delete(postRef);

  // 11. (Optionnel) : NE PAS supprimer l'utilisateur

  // Commit du batch
  await batch.commit();

  return { success: true };
});
