const admin = require('firebase-admin');

/**
 * Fonction qui supprime toutes les ressources liées à un post
 * @param {string} postId - L'ID du post supprimé
 * @param {object} postData - Les données du post supprimé
 */
async function cleanupPostResources(postId, postData) {
  console.log(`Post ${postId} supprimé, nettoyage des ressources associées...`);
  
  try {
    // 1. Supprimer les images du post dans Storage
    if (postData.blocs && Array.isArray(postData.blocs)) {
      const deleteImagePromises = [];
      
      for (const bloc of postData.blocs) {
        if (bloc.postImageUrl) {
          try {
            console.log(`Suppression de l'image: ${bloc.postImageUrl}`);
            const imageRef = admin.storage().refFromURL(bloc.postImageUrl);
            deleteImagePromises.push(imageRef.delete());
          } catch (error) {
            console.error(`Erreur lors de la suppression de l'image: ${error}`);
          }
        }
      }
      
      await Promise.all(deleteImagePromises);
      console.log('Toutes les images ont été supprimées avec succès');
    }
    
    // 2. Supprimer les références dans les sous-collections des utilisateurs
    const usersRef = admin.firestore().collection('users');
    const usersSnapshot = await usersRef.get();
    
    // Pour chaque utilisateur, supprimer les références au post
    const userUpdatePromises = [];
    
    usersSnapshot.forEach(userDoc => {
      const userId = userDoc.id;
      const userUpdateBatch = [];
      
      // Collections à nettoyer pour chaque utilisateur
      const userCollections = [
        'commentsPosts',    // Commentaires de l'utilisateur
        'likedComments',    // Commentaires aimés
        'likedPosts',       // Posts aimés
        'reportedPosts',    // Posts signalés
        'savedPosts',       // Posts enregistrés
        'votes'            // Votes de l'utilisateur
      ];
      
      // Ajouter les suppressions à la liste des promesses
      userCollections.forEach(collection => {
        const deletePromise = deleteUserSubcollection(userId, collection, 'postId', postId);
        userUpdateBatch.push(deletePromise);
      });
      
      userUpdatePromises.push(Promise.all(userUpdateBatch));
    });
    
    // Attendre que toutes les mises à jour utilisateur soient terminées
    await Promise.all(userUpdatePromises);
    console.log('Toutes les références utilisateur ont été supprimées');
    
    console.log(`Nettoyage complet pour le post ${postId} terminé avec succès`);
    return true;
  } catch (error) {
    console.error(`Erreur lors du nettoyage des ressources pour le post ${postId}:`, error);
    return false;
  }
}

/**
 * Supprime les documents d'une sous-collection utilisateur
 */
async function deleteUserSubcollection(userId, collectionName, field, value) {
  try {
    const snapshot = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection(collectionName)
      .where(field, '==', value)
      .get();
    
    if (snapshot.empty) return 0;
    
    console.log(`Suppression de ${snapshot.size} documents dans users/${userId}/${collectionName}`);
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    return snapshot.size;
  } catch (error) {
    console.error(`Erreur lors de la suppression dans users/*/${collectionName}:`, error);
    return 0;
  }
}

module.exports = {
  cleanupPostResources
};
