// server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const compression = require('compression');

const TripRoute = require("./models/Routes")

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

const router = express.Router()

// MongoDB connection
const mongoURI = process.env.MONGODB_URI;
mongoose.connect(mongoURI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Import routes
const Authentication_Router = require("./Routes/authentication");
const Routes = require('./models/Routes');

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

// // Use route modules
// app.use(compression());

// Error handling middleware
app.use((error, req, res, next) => {
  if (error instanceof SyntaxError && error.status === 413) {
    res.status(413).json({ message: "Payload too large", error: error.message });
  } else {
    next();
  }
});

app.get("/allRoutes", async (req, res) => {
  try {
    const routes = await TripRoute.find()
    res.status(200).json(routes);
  } catch (error) {
    console.error("Error fetching routes:", error);
    res.status(500).json({ message: "Failed to fetch routes", error: error.message });
  }
});

app.get("/Trip/:id", async (req, res) => {
  try {
    const route = await TripRoute.findById(req.params.id);
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    res.status(200).json(route);
  } catch (error) {
    console.error("Error fetching route:", error);
    res.status(500).json({ message: "Failed to fetch route", error: error.message });
  }
});


// For getting the camera information
app.post("/UploadImage", async (req,res) => {
  console.log("something is here ")
  let Content = await req.body;
  console.log(Content);
})



app.post("/Routes", async (req, res) => {
  console.log("Request received to /api/routes");
  
  try {
    const { Name_Route, Path_Cordinate, userProfile, userName, MemoriesTrip } = req.body;
    
    // Validate input
    if (!Name_Route || !Path_Cordinate || !userProfile || !userName) {
      console.log("Missing fields:", { Name_Route, Path_Cordinate, userProfile, userName });
      return res.status(400).json({ 
        message: "Missing required fields",
        received: { Name_Route, Path_Cordinate, userProfile, userName }
      });
    }

    // Create new route object
    const newRoute = new TripRoute({
      Name_Route,
      Path_Cordinate,
      userProfile,
      userName,
      MemoriesTrip: MemoriesTrip || [] // Make this optional
    });

    // Save the route
    await newRoute.save();
    
    console.log("Route saved successfully");
    res.status(200).json({ 
      message: "Route saved successfully", 
      route: newRoute 
    });
    
  } catch (error) {
    console.error("Error saving route:", error);
    res.status(500).json({ 
      message: "Failed to save route", 
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});
app.use("/auth", Authentication_Router);  // Assuming you want to use this router

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});
// here for the updating of the event
app.put("/updateRoute/:id", async(req,res) => {
  console.log(req.params.id)
  
try {
  let idNow = req.params.id
  let {Name_Route} = req.body;
  let isthere = await TripRoute.findByIdAndUpdate({
    id: idNow,
    Name_Route : Name_Route
  })
  if (isthere) {
    console.log(isthere);
    req.json({
      success: true,
      message :"editing completed"
    })
  }
} catch (error) {
 console.log(error) 
}
})

// For local development
if (process.env.NODE_ENV !== 'production') {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}



module.exports = app;