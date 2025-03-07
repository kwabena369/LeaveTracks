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

AuthenticationRouter.post('/sync', async (req, res) => {
  try {
    const { uid, username, email, googleid, avatar_url } = req.body;
    
    let user = await Userscheman.findOne({ $or: [{ uid }, { email }] });
    
    if (!user) {
      user = new Userscheman({
        username,
        Email: email,
        googleid,
        avatar_url,
        uid,
      });
    } else {
      user.username = username || user.username;
      user.avatar_url = avatar_url || user.avatar_url;
      user.updateAt = Date.now();
    }
    
    await user.save();
    res.status(201).json(user);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: `Error: ${error.message}` });
  }
});

module.exports = AuthenticationRouter