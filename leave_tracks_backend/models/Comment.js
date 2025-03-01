const mongoose = require("mongoose");

const CommentSchema = new mongoose.Schema({
  routeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'TripRoute',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  userName: {
    type: String,
    required: true
  },
  userProfile: {
    type: String,
    default: "/cat.png"
  },
  content: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  likes: {
    type: Number,
    default: 0
  }
});

module.exports = mongoose.model("Comment", CommentSchema);