// models/Coordinates.js
let mongoose = require("mongoose");

const CoordinateSchema = require("./Cordinates")
const RouteSchema = new mongoose.Schema({
  userProfile: {
    type: String,
    required: false,
    default :"/cat.png"
  },
  userName: {
    type: String,
    required: false ,
    default : "kogi"
  }
  ,
  Name_Route: {
    type: String,
    required: true
  },
  Path_Cordinate: [],
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