const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const { deletePostAndAllData } = require('./deletePostAndAllData');
const { deleteCommentAndLikes } = require('./deleteCommentAndLikes');

exports.deletePostAndAllData = deletePostAndAllData;
exports.deleteCommentAndLikes = deleteCommentAndLikes;