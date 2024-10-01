//  the schma for the route
const mongoose = require("mongoose");
const Cordinates = require("./Cordinates");
//  the real dela
const RouteSchema = new mongoose.Schema({
    Author_Route: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
    ,
    Name_Route: {
        type: String,
        required: true
    },
    Path_Cordinate: [
        Cordinates
    ]
    ,
    createAt: { 
         type: Date,
         default : Date.now
     }
    ,
    updateAt: {
        type: Date,
        default : Date.now
    }
    //  the arrow that keep the various log and lat information 
})

//  making it available 
module.exports  =  mongoose.model("Route",RouteSchema)