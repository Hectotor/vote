const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialisation de Firebase Admin (une seule fois)
admin.initializeApp();

// Import de la fonction deleteCommentAndLikes
const { deleteCommentAndLikes } = require('./deleteCommentAndLikes');

// Export des fonctions Cloud
exports.deleteCommentAndLikes = deleteCommentAndLikes;
