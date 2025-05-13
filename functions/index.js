const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialisation de Firebase Admin (une seule fois)
admin.initializeApp();

// Import de la fonction togglePostLike
const deleteCommentAndLikes = require('./deleteCommentAndLikes');

// Export des fonctions Cloud
exports.deleteCommentAndLikes = functions.https.onCall(deleteCommentAndLikes.deleteCommentAndLikes);
