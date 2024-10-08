// server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// MongoDB connection
const mongoURI = process.env.MONGODB_URI;
mongoose.connect(mongoURI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Import routes
const Authentication_Router = require("./Routes/authentication");

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Leave Tracks Backend' });
});

app.get("/SavedRoutes", (req, res) => {
  //   tryp
  console.log("there is the kit")
  res.json({
    message: "There is something Big ",
    TripValues: [
      {
        nameTrip: "Aunti Ama place to whatever",
        profileTrip : "/whatever.png"
        
      }
    ]
  })
})
//  handling of the user inforamtion for the 
app.post("/Content", (req, res) => {
  console.log(req.body);
  res.status(200).json({
     message  : "ghost are real"
  })
})

app.post('/test', (req, res) => {
  console.log('Received message:', req.body.message);
  res.json({ status: 'Message received', message: req.body.message });
});

// Use route modules
app.post("/Routes", (req, res) => {
  console.log("someone is saving route");


});
app.use("/auth", Authentication_Router);  // Assuming you want to use this router

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// For local development
if (process.env.NODE_ENV !== 'production') {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

module.exports = app;