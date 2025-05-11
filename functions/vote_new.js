const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Fonction pour gérer les votes
 * @param {Object} data - Données du vote
 * @param {string} data.postId - ID du post
 * @param {number} data.blockIndex - Index du bloc sur lequel on vote
 * @returns {Promise<void>}
 */
exports.vote = async (data, context) => {
  try {
    const { postId, blockIndex } = data;
    const userId = context.auth.uid;

    if (!userId) {
      throw new Error('L\'utilisateur doit être connecté');
    }

    const db = admin.firestore();
    const postRef = db.collection('posts').doc(postId);
    const postDoc = await postRef.get();

    if (!postDoc.exists) {
      throw new Error('Post non trouvé');
    }

    const postData = postDoc.data();
    const blocs = postData.blocs;
    
    // Vérifier si l'utilisateur a déjà voté
    let hasVoted = false;
    for (const bloc of blocs) {
      if (bloc.votes && bloc.votes.includes(userId)) {
        hasVoted = true;
        break;
      }
    }

    if (hasVoted) {
      throw new Error('Vous avez déjà voté sur ce sondage');
    }

    // Mettre à jour le bloc
    const bloc = blocs[blockIndex];
    if (!bloc) {
      throw new Error('Bloc non trouvé');
    }

    const updatedBloc = {
      ...bloc,
      voteCount: (bloc.voteCount || 0) + 1,
      votes: [...(bloc.votes || []), userId],
    };

    // Mettre à jour le post
    const updatedBlocs = [...blocs];
    updatedBlocs[blockIndex] = updatedBloc;

    await postRef.update({
      blocs: updatedBlocs
    });

    console.log('Vote enregistré avec succès');
    return { success: true };
  } catch (error) {
    console.error('Erreur lors du vote:', error);
    throw error;
  }
};
