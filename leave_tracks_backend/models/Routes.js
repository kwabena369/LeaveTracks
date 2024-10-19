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
  //  this section is a section that is definately not required
  MemoriesTrip: [
    {
      ImageContent: String,
      Location: {
        lat: Number,
        long : Number
      }
    }
    
  ]
});

module.exports = mongoose.model("TripRoute", RouteSchema);