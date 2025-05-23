const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

const deletePostAndAllData = require('./deletePostAndAllData');
const deleteCommentAndLikes = require('./deleteCommentAndLikes');
const deleteUserAccount = require('./deleteUserAccount');

// Fonction callable pour suppression complète d'un post et de tout son contenu lié (Firestore + Storage)
exports.deletePostAndAllData = onCall(async (request) => {
  const postId = request.data.postId;
  const userId = request.auth?.uid;
  return await deletePostAndAllData(postId, userId);
});

// Fonction callable pour suppression d'un commentaire et de tous ses likes
exports.deleteCommentAndLikes = onCall(async (request) => {
  const { commentId, postId } = request.data;
  return await deleteCommentAndLikes({ commentId, postId }, request.auth);
});

// Fonction callable pour suppression d'un compte et de toutes ses données
exports.deleteUserAccount = onCall(async (request) => {
  const userId = request.auth?.uid;
  return await deleteUserAccount(userId);
});
