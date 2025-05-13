const admin = require('firebase-admin');

// Note: Nous initialisons Firebase Admin uniquement dans index.js pour u00e9viter les doubles initialisations
const functions = require('firebase-functions');

// Export direct de la fonction (sera encapsulu00e9e avec onCall dans index.js)
module.exports = async (data, context) => {
  console.log('Toggle Post Like function called', { data, auth: context.auth });
  
  // Vérification de l'authentification
  if (!context.auth) {
    console.error('No auth context');
    throw new functions.https.HttpsError("unauthenticated", "L'utilisateur doit être authentifié");
  }
  
  const uid = context.auth.uid;
  const postId = data.postId;

  if (!postId) {
    console.error('Missing postId');
    throw new functions.https.HttpsError("invalid-argument", "Missing postId");
  }
  
  console.log(`Processing like toggle for user ${uid} on post ${postId}`);


  const postRef = admin.firestore().doc(`posts/${postId}`);
  const likeRef = postRef.collection("likedPosts").doc(uid);

  const likeSnap = await likeRef.get();

  if (likeSnap.exists) {
    // UNLIKE
    await likeRef.delete();
    await postRef.update({
      likesCount: admin.firestore.FieldValue.increment(-1),
    });
    return { liked: false };
  } else {
    // LIKE
    await likeRef.set({
      userId: uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await postRef.update({
      likesCount: admin.firestore.FieldValue.increment(1),
    });
    return { liked: true };
  }
};
