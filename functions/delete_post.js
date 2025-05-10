const admin = require('firebase-admin');

/**
 * Fonction qui supprime toutes les ressources liu00e9es u00e0 un post
 * @param {string} postId - L'ID du post supprimu00e9
 * @param {object} postData - Les donnu00e9es du post supprimu00e9
 */
async function cleanupPostResources(postId, postData) {
  console.log(`Post ${postId} supprimu00e9, nettoyage des ressources associu00e9es...`);
  
  try {
    // Supprimer les images du post dans Storage
    if (postData.blocs && Array.isArray(postData.blocs)) {
      const deleteImagePromises = [];
      
      for (const bloc of postData.blocs) {
        if (bloc.postImageUrl) {
          try {
            console.log(`Suppression de l'image: ${bloc.postImageUrl}`);
            // Obtenir la ru00e9fu00e9rence de l'image u00e0 partir de l'URL
            const imageRef = admin.storage().refFromURL(bloc.postImageUrl);
            deleteImagePromises.push(imageRef.delete());
          } catch (error) {
            console.error(`Erreur lors de la suppression de l'image: ${error}`);
          }
        }
      }
      
      // Attendre que toutes les suppressions d'images soient terminu00e9es
      await Promise.all(deleteImagePromises);
      console.log('Toutes les images ont u00e9tu00e9 supprimu00e9es avec succu00e8s');
    }
    
    // Supprimer les commentaires associu00e9s
    await deleteCollection('comments', 'postId', postId);
    
    // Supprimer les likes associu00e9s
    await deleteCollection('likes', 'postId', postId);
    
    // Supprimer les hashtags associu00e9s
    await deleteCollection('hashtags', 'postId', postId);
    
    // Supprimer les mentions associu00e9es
    await deleteCollection('mentions', 'postId', postId);
    
    // Supprimer les notifications associu00e9es
    await deleteCollection('notifications', 'postId', postId);
    
    // Supprimer les rapports associu00e9s
    await deleteCollection('reports', 'postId', postId);
    
    console.log(`Nettoyage complet pour le post ${postId} terminu00e9 avec succu00e8s`);
    return true;
  } catch (error) {
    console.error(`Erreur lors du nettoyage des ressources pour le post ${postId}: ${error}`);
    return false;
  }
}

/**
 * Fonction utilitaire pour supprimer tous les documents d'une collection
 * qui correspondent u00e0 une requu00eate spu00e9cifique
 * @param {string} collectionName - Nom de la collection
 * @param {string} field - Champ u00e0 filtrer
 * @param {string} value - Valeur du champ u00e0 rechercher
 */
async function deleteCollection(collectionName, field, value) {
  try {
    const snapshot = await admin.firestore()
      .collection(collectionName)
      .where(field, '==', value)
      .get();
    
    console.log(`Suppression de ${snapshot.size} documents dans ${collectionName}`);
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    if (snapshot.size > 0) {
      await batch.commit();
      console.log(`${snapshot.size} documents supprimu00e9s de ${collectionName}`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la suppression des documents dans ${collectionName}: ${error}`);
    return false;
  }
}

module.exports = {
  cleanupPostResources
};
