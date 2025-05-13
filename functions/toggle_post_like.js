const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.togglePostLike = functions.https.onCall(async (data, context) => {
  const uid = context.auth && context.auth.uid;
  const postId = data.postId;

  if (!uid || !postId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing uid or postId");
  }

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
});
