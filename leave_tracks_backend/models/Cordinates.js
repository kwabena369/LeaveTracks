//  the schma for the route
const mongoose = require("mongoose");

// chema for cordinate
const CordinateSchema = await mongoose.Schema({
    longitube: {
        type: Number,
        required : true
    },
    latitude: {
        type: Number,
        required : true
    },
    timeStamp: {
        type: Date,
        default : Date.now
    }
})
//   making is available
module.exports = await mongoose.model("Cordinate", CordinateSchema);