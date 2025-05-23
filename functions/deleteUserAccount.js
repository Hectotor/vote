const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Fonction pour supprimer un compte utilisateur et toutes les données associées
 * Cette fonction supprime :
 * - Le document utilisateur
 * - Tous les posts de l'utilisateur
 * - Tous les commentaires de l'utilisateur
 * - Tous les likes, votes, followers, etc. liés à l'utilisateur
 */
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  // Vérifier si l'utilisateur est authentifié
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vous devez être connecté pour supprimer votre compte');
  }

  const userId = context.auth.uid;
  console.log(`Suppression du compte utilisateur: ${userId}`);

  try {
    // 1. Récupérer les informations de l'utilisateur
    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnap = await userRef.get();
    
    if (!userSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Utilisateur introuvable');
    }

    // 2. Récupérer tous les posts de l'utilisateur
    const postsQuery = await admin.firestore().collection('posts')
      .where('userId', '==', userId)
      .get();
    
    // 3. Supprimer chaque post et ses données associées
    const postDeletionPromises = [];
    postsQuery.forEach(postDoc => {
      const postId = postDoc.id;
      postDeletionPromises.push(deletePostAndAllData(postId, userId));
    });
    
    await Promise.all(postDeletionPromises);
    console.log(`Suppression de ${postDeletionPromises.length} posts terminée`);

    // 4. Supprimer les commentaires de l'utilisateur
    const commentsQuery = await admin.firestore().collection('commentsPosts')
      .where('userId', '==', userId)
      .get();
    
    const commentDeletionPromises = [];
    commentsQuery.forEach(commentDoc => {
      commentDeletionPromises.push(admin.firestore().collection('commentsPosts').doc(commentDoc.id).delete());
    });
    
    await Promise.all(commentDeletionPromises);
    console.log(`Suppression de ${commentDeletionPromises.length} commentaires terminée`);

    // 5. Supprimer les likes de l'utilisateur
    const likesDeletionPromises = [];
    const likesQuery = await admin.firestore().collection('likes')
      .where('userId', '==', userId)
      .get();
    
    likesQuery.forEach(likeDoc => {
      likesDeletionPromises.push(admin.firestore().collection('likes').doc(likeDoc.id).delete());
    });
    
    await Promise.all(likesDeletionPromises);
    console.log(`Suppression de ${likesDeletionPromises.length} likes terminée`);

    // 6. Supprimer les votes de l'utilisateur
    const votesDeletionPromises = [];
    const votesQuery = await admin.firestore().collection('votesPosts')
      .where('userId', '==', userId)
      .get();
    
    votesQuery.forEach(voteDoc => {
      votesDeletionPromises.push(admin.firestore().collection('votesPosts').doc(voteDoc.id).delete());
    });
    
    await Promise.all(votesDeletionPromises);
    console.log(`Suppression de ${votesDeletionPromises.length} votes terminée`);

    // 7. Supprimer les relations followers/following
    const followerPromises = [];
    
    // Supprimer où l'utilisateur est follower
    const followingQuery = await admin.firestore().collection('followers')
      .where('followerId', '==', userId)
      .get();
    
    followingQuery.forEach(followDoc => {
      const followedId = followDoc.data().followedId;
      followerPromises.push(admin.firestore().collection('followers').doc(followDoc.id).delete());
      
      // Décrémenter le compteur de followers pour les utilisateurs suivis
      followerPromises.push(
        admin.firestore().collection('users').doc(followedId).update({
          followersCount: admin.firestore.FieldValue.increment(-1)
        })
      );
    });
    
    // Supprimer où l'utilisateur est suivi
    const followersQuery = await admin.firestore().collection('followers')
      .where('followedId', '==', userId)
      .get();
    
    followersQuery.forEach(followDoc => {
      const followerId = followDoc.data().followerId;
      followerPromises.push(admin.firestore().collection('followers').doc(followDoc.id).delete());
      
      // Décrémenter le compteur de following pour les utilisateurs qui suivent
      followerPromises.push(
        admin.firestore().collection('users').doc(followerId).update({
          followingCount: admin.firestore.FieldValue.increment(-1)
        })
      );
    });
    
    await Promise.all(followerPromises);
    console.log(`Suppression des relations followers terminée`);

    // 8. Supprimer les notifications liées à l'utilisateur
    const notificationsPromises = [];
    
    // Notifications créées par l'utilisateur
    const sentNotificationsQuery = await admin.firestore().collection('notifications')
      .where('fromUserId', '==', userId)
      .get();
    
    sentNotificationsQuery.forEach(notifDoc => {
      notificationsPromises.push(admin.firestore().collection('notifications').doc(notifDoc.id).delete());
    });
    
    // Notifications reçues par l'utilisateur
    const receivedNotificationsQuery = await admin.firestore().collection('notifications')
      .where('toUserId', '==', userId)
      .get();
    
    receivedNotificationsQuery.forEach(notifDoc => {
      notificationsPromises.push(admin.firestore().collection('notifications').doc(notifDoc.id).delete());
    });
    
    await Promise.all(notificationsPromises);
    console.log(`Suppression des notifications terminée`);

    // 9. Supprimer les posts sauvegardés par l'utilisateur
    const savedPostsPromises = [];
    const savedPostsQuery = await admin.firestore().collection('savedPosts')
      .where('userId', '==', userId)
      .get();
    
    savedPostsQuery.forEach(savedDoc => {
      savedPostsPromises.push(admin.firestore().collection('savedPosts').doc(savedDoc.id).delete());
    });
    
    await Promise.all(savedPostsPromises);
    console.log(`Suppression des posts sauvegardés terminée`);

    // 10. Supprimer le document utilisateur
    await userRef.delete();
    console.log(`Document utilisateur supprimé`);

    // 11. Supprimer le compte d'authentification Firebase
    await admin.auth().deleteUser(userId);
    console.log(`Compte d'authentification supprimé`);

    return { success: true, message: "Compte supprimé avec succès" };
  } catch (error) {
    console.error('Erreur lors de la suppression du compte:', error);
    throw new functions.https.HttpsError('internal', `Erreur lors de la suppression du compte: ${error.message}`);
  }
});

/**
 * Fonction utilitaire pour supprimer un post et toutes ses données associées
 * Cette fonction est similaire à la fonction deletePostAndAllData existante
 */
async function deletePostAndAllData(postId, userId) {
  console.log(`Suppression du post ${postId}`);
  
  // Supprimer les sous-collections et documents liés
  const collectionsToDelete = [
    'commentLikes', 'commentsPosts', 'hashtags',
    'likes', 'mentions', 'notifications', 'reportedPosts',
    'savedPosts', 'votesPosts'
  ];

  for (const col of collectionsToDelete) {
    const snap = await admin.firestore().collection(col).where('postId', '==', postId).get();
    const deletePromises = [];
    
    snap.forEach(doc => {
      deletePromises.push(admin.firestore().collection(col).doc(doc.id).delete());
    });
    
    await Promise.all(deletePromises);
    console.log(`Suppression de ${deletePromises.length} documents dans ${col} pour le post ${postId}`);
  }

  // Supprimer le document du post lui-même
  await admin.firestore().collection('posts').doc(postId).delete();
  console.log(`Post ${postId} supprimé`);

  return true;
}
