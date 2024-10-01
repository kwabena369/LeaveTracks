// models/Coordinates.js
const mongoose = require("mongoose");

const CoordinateSchema = new mongoose.Schema({
  latitude: {
    type: Number,
    required: true
  },
  longitude: {
    type: Number,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = CoordinateSchema;

// models/Route.js