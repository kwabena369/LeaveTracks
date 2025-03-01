// server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const compression = require('compression');
const Comment = require("./models/Comment");

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



// Get comments for a specific route
app.get("/comments/:routeId", async (req, res) => {
  try {
    const comments = await Comment.find({ routeId: req.params.routeId })
      .sort({ createdAt: -1 }); // Sort by newest first
    
    res.status(200).json(comments);
  } catch (error) {
    console.error("Error fetching comments:", error);
    res.status(500).json({ message: "Failed to fetch comments", error: error.message });
  }
});

// Add a new comment
app.post("/comments", async (req, res) => {
  try {
    const { routeId, userId, userName, userProfile, content } = req.body;
    
    if (!routeId || !userId || !userName || !content) {
      return res.status(400).json({ 
        message: "Missing required fields",
        received: { routeId, userId, userName, content }
      });
    }
    
    const newComment = new Comment({
      routeId,
      userId,
      userName,
      userProfile: userProfile || "/cat.png",
      content
    });
    
    await newComment.save();
    
    res.status(201).json({ 
      message: "Comment added successfully", 
      comment: newComment 
    });
  } catch (error) {
    console.error("Error adding comment:", error);
    res.status(500).json({ 
      message: "Failed to add comment", 
      error: error.message
    });
  }
});

// Like a route
app.post("/routes/like/:id", async (req, res) => {
  try {
    const route = await TripRoute.findById(req.params.id);
    
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    
    route.likes += 1;
    await route.save();
    
    res.status(200).json({ 
      message: "Route liked successfully", 
      likes: route.likes 
    });
  } catch (error) {
    console.error("Error liking route:", error);
    res.status(500).json({ 
      message: "Failed to like route", 
      error: error.message 
    });
  }
});

// Dislike a route
app.post("/routes/dislike/:id", async (req, res) => {
  try {
    const route = await TripRoute.findById(req.params.id);
    
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    
    route.dislikes += 1;
    await route.save();
    
    res.status(200).json({ 
      message: "Route disliked successfully", 
      dislikes: route.dislikes 
    });
  } catch (error) {
    console.error("Error disliking route:", error);
    res.status(500).json({ 
      message: "Failed to dislike route", 
      error: error.message 
    });
  }
});

// Update route privacy
app.put("/routes/privacy/:id", async (req, res) => {
  try {
    const { isPublic, authorizedViewers } = req.body;
    
    if (isPublic === undefined) {
      return res.status(400).json({ message: "Missing isPublic field" });
    }
    
    const updateData = { isPublic };
    
    // If route is private and authorizedViewers are provided
    if (!isPublic && authorizedViewers && Array.isArray(authorizedViewers)) {
      updateData.authorizedViewers = authorizedViewers;
    }
    
    const route = await TripRoute.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );
    
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    
    res.status(200).json({ 
      message: "Route privacy updated successfully", 
      route 
    });
  } catch (error) {
    console.error("Error updating route privacy:", error);
    res.status(500).json({ 
      message: "Failed to update route privacy", 
      error: error.message 
    });
  }
});

// Get public routes or routes the user is authorized to view
app.get("/routes/accessible/:userId", async (req, res) => {
  try {
    const routes = await TripRoute.find({
      $or: [
        { isPublic: true },
        { authorizedViewers: req.params.userId }
      ]
    });
    
    res.status(200).json(routes);
  } catch (error) {
    console.error("Error fetching accessible routes:", error);
    res.status(500).json({ 
      message: "Failed to fetch accessible routes", 
      error: error.message 
    });
  }
});


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
//  here it is specifically for rerouting 
app.post("/Reroutes",async (req, res) => {
    try {
      const { Name_Route, Path_Cordinate, userProfile, userName, MemoriesTrip,RouteId } = req.body;
  
        if (!Name_Route || !Path_Cordinate || !userProfile || !userName||!RouteId) {
        console.log("Missing fields:", { Name_Route, Path_Cordinate, userProfile, userName });
        return res.status(400).json({ 
          message: "Missing required fields",
          received: { Name_Route, Path_Cordinate, userProfile, userName }
        });
      }
  
    
    //  the recreation of the  route values
     const  routerNow = await TripRoute.updateOne({
      id: RouteId,
      Path_Cordinate : Path_Cordinate
     })
    await routerNow.save()
        
      console.log("Route saved successfully");
      res.status(200).json({ 
        message: "Route saved successfully", 
        route: newRoute 
      });
    } catch (error) {
      console.log(error);
      console.error("Error saving route:", error);
    res.status(500).json({ 
      message: "Failed to save route", 
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
    }

})
app.use("/auth", Authentication_Router);  // Assuming you want to use this router

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});
// here for the updating of the event
app.put("/updateRoute/:id", async(req,res) => {
  console.log(req.params.id)
  console.log("from backend")
  
try {
  let idNow = req.params.id
  let {Name_Route} = req.body;


  let isthere = await TripRoute.updateOne({
    id: idNow,
    Name_Route : Name_Route
  })
  if (isthere) {
    console.log(isthere);
    res.json({
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
  const port = process.env.PORT || 3001;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

// Endpoint to increment view count when a route is viewed
app.post("/routes/view/:id", async (req, res) => {
  try {
    const { userId } = req.body; // Optional: If you want to track unique viewers
    
    const route = await TripRoute.findById(req.params.id);
    
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    
    // Increment the view count
    route.views += 1;
    
    // If userId is provided and user hasn't viewed this route before
    if (userId && !route.uniqueViewers.includes(userId)) {
      route.uniqueViewers.push(userId);
    }
    
    await route.save();
    
    res.status(200).json({ 
      message: "View counted successfully", 
      views: route.views,
      uniqueViewers: route.uniqueViewers.length
    });
  } catch (error) {
    console.error("Error counting view:", error);
    res.status(500).json({ 
      message: "Failed to count view", 
      error: error.message 
    });
  }
});

// Get route with view count
app.get("/routes/stats/:id", async (req, res) => {
  try {
    const route = await TripRoute.findById(req.params.id);
    
    if (!route) {
      return res.status(404).json({ message: "Route not found" });
    }
    
    res.status(200).json({
      routeId: route._id,
      name: route.Name_Route,
      views: route.views,
      uniqueViewers: route.uniqueViewers.length,
      likes: route.likes,
      dislikes: route.dislikes,
      commentCount: await Comment.countDocuments({ routeId: route._id })
    });
  } catch (error) {
    console.error("Error getting route stats:", error);
    res.status(500).json({ 
      message: "Failed to get route stats", 
      error: error.message 
    });
  }
});

// Get most viewed routes (could be useful for "trending" or "popular" routes)
app.get("/routes/popular", async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    
    const popularRoutes = await TripRoute.find({ isPublic: true })
      .sort({ views: -1 })
      .limit(limit);
    
    res.status(200).json(popularRoutes);
  } catch (error) {
    console.error("Error getting popular routes:", error);
    res.status(500).json({ 
      message: "Failed to get popular routes", 
      error: error.message 
    });
  }
});


module.exports = app;