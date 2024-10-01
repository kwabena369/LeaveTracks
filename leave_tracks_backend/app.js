const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express()


//   the various router to be used 
const Route_Router = require("./Routes/routes")
const Authentication_Router = require("./Routes/authentication")


// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Leave Tracks Backend' });
});

app.post('/test', (req, res) => {
  console.log('Received message:', req.body.message);
  res.json({ status: 'Message received', message: req.body.message });
});

//   for the locaiton staff
app.use("/Routes", Route_Router);


// app.post('/location', async (req, res) => {
//   try {

//     //  the location schma  
//      const Cordinate = await require("./models/Cordinates")
    

//     const { latitude, longitude } = req.body;
//     const newLocation = new Cordinate({ latitude, longitude });
//     await newLocation.save();
//     res.json({ status: 'Location saved successfully', location: newLocation });
//   } catch (error) {
//     console.error('Error saving location:', error);
//     res.status(500).json({ error: 'Error saving location', details: error.message });
//   }
// });

// app.get('/locations', async (req, res) => {
//   try {
//     const locations = await Location.find().sort({ timestamp: -1 }).limit(10);
//     res.json(locations);
//   } catch (error) {
//     console.error('Error fetching locations:', error);
//     res.status(500).json({ error: 'Error fetching locations', details: error.message });
//   }
// });




module.exports =app