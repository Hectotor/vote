const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialisation de Firebase Admin (une seule fois)
admin.initializeApp();

// Import de la fonction togglePostLike
const togglePostLike = require('./toggle_post_like');

// Export des fonctions Cloud
exports.togglePostLike = functions.https.onCall(togglePostLike);
