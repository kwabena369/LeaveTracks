//  here is for the creation of 
const express = require("express");
const Route_Router = express.Router();

// the various schema for thedb
const RouteSchema = require("../models/Routes");
const CordinateSchema = require("../models/Cordinates")
 

//  for the default thing when someone is here
RouteSchema.get("/", (req,res) => {
    console.log(req)
    res.status(200).json({
         message : "it isdone in the back"
    })
})


//   for the sake of _debuging
Route_Router.get("/All_Routes", async (req,res)=>{
     
    try {
        
        let All_route_now = await RouteSchema.find()
 
    
    res.status(200).json({
        meesage: All_route_now
    })
        
    } catch (error) {
        res.status(500).json({
              message : `${error.meesage}`
         })}
     }

)

//  the router been available
module.exports = Route_Router