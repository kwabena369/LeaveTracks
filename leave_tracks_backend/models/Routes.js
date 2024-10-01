// models/Coordinates.js
let mongoose = require("mongoose");

const CoordinateSchema = require("./Cordinates")
const RouteSchema = new mongoose.Schema({
  Author_Route: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  Name_Route: {
    type: String,
    required: true
  },
  Path_Cordinate: [CoordinateSchema],
  createAt: {
    type: Date,
    default: Date.now
  },
  updateAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Route", RouteSchema);