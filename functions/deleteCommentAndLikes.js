const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteCommentAndLikes = functions.https.onCall(async (data, context) => {
  const { commentId, postId } = data;
  // Vérifier que l'utilisateur est authentifié
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  // Récupérer le commentaire
  const commentRef = admin.firestore().collection('commentsPosts').doc(commentId);
  const commentSnap = await commentRef.get();
  if (!commentSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Comment not found.');
  }
  // Vérifier que l'utilisateur est bien l'auteur du commentaire
  if (commentSnap.data().userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Not the comment owner.');
  }

  // Supprimer tous les likes associés à ce commentaire
  const likesQuery = await admin.firestore()
    .collection('commentLikes')
    .where('commentId', '==', commentId)
    .get();

  const batch = admin.firestore().batch();
  likesQuery.forEach(doc => batch.delete(doc.ref));
  batch.delete(commentRef);

  // Décrémenter le compteur de commentaires du post
  const postRef = admin.firestore().collection('posts').doc(postId);
  batch.update(postRef, {
    commentCount: admin.firestore.FieldValue.increment(-1),
  });

  await batch.commit();

  return { success: true };
});