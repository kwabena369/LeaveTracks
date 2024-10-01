//   this is the schema for Registered users
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs")
 
//  the schema for user 
const UserScheman= new mongoose.Schema({
    usename: 
    {
        type: String,
        required: true,
        unique : true 
    }
    ,
    Email: {
        type: String,
        required: true ,
         unique : true 

    }
    ,
    googleid: {
        type: String,
       
        sparse: true 
    },
    avatar_url: {
        type: String
    },
    password: {
        type: String,
        required: function () { return !this.googleid; },

    }
     ,createAt: { 
         type: Date,
         default : Date.now()
     }
    ,
    updateAt: {
        type: Date,
        default : Date.now()
     }
})
//  before the user is saved into the db we encrypt the password
Userscheman.pre("save", async(next) => {
    if (this.isModified("password")) {
        //    the changing of the password
        this.password = await bcrypt.hash(this.password,10)
 }
     next()
})  
// exporting the things
module.exports =  mongoose.model("User",UserScheman)