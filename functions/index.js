const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

const deletePostAndAllData = require('./deletePostAndAllData');

// Fonction callable pour suppression complète d'un post et de tout son contenu lié (Firestore + Storage)
exports.deletePostAndAllData = onCall(async (request) => {
  const postId = request.data.postId;
  const userId = request.auth?.uid;
  return await deletePostAndAllData(postId, userId);
});