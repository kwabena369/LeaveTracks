//  the user
const Userscheman = require("../models/User")
const bcrypt = require("bcryptjs")
const express = require("express")
//  authentication router
const AuthenticationRouter = express.Router()
 
//  for the debuging sake...
AuthenticationRouter.get("/AllUser",  async(req,res)=>{
    try {
        //  all users : 
        let user = await Userscheman.find();
        res.status(200).json({
          message : `${user}`   
        })
     } catch (error) {
         console.log(error)
         res.status(500).json({
            message : `Error_in the backend - ${error.message}`
         })
     }
})
