//   this schma is for storing of memories
let mongoose = require("mongoose");

//  the information 

const MemorySchema = new  mongoose.Schema({
    User: {
        require: true,
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
    },
    // the value of the cordinate 
    Current_location: { 
        latitude: {
            type: Number,
            required : true 
        },
        longitude: {
            type: Number,
            required  :true 
        }
    },
    timeStamp: {
        type: Date,
        default  : Date.now,
    }
    ,
    createAt: {
        type: Date,
        default : Date.now
    },
    //  the cotent informatiuon url and the ofkind
    Content_url: {
        type: String,
        required : true
    },
    //   OfKind
    Of_Kind: {
        type: String,
        required : true
    }

})

module.exports = mongoose.model("Memory",MemorySchema)