const mongoose = require("mongoose");

const RouteSchema = new mongoose.Schema({
  userProfile: {
    type: String,
    required: false,
    default: "/cat.png"
  },
  userName: {
    type: String,
    required: false,
    default: "kogi"
  },
  Name_Route: {
    type: String,
    required: true
  },
  Path_Cordinate: [{
    latitude: Number,
    longitude: Number
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  // New fields for likes, privacy, etc.
  likes: {
    type: Number,
    default: 0
  },
  dislikes: {
    type: Number,
    default: 0
  },
  // View counter to track number of viewers
  views: {
    type: Number,
    default: 0
  },
  // Optional: Track unique viewers
  uniqueViewers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  isPublic: {
    type: Boolean,
    default: true
  },
  authorizedViewers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  // This section is for memories
  MemoriesTrip: [
    {
      ImageContent: String,
      Location: {
        lat: Number,
        long: Number
      }
    }
  ]
});

module.exports = mongoose.model("TripRoute", RouteSchema);