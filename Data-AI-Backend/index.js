/**
 * Purpose: Express server to communicate between the app and OpenAI chat session manager
 * 
 * This is a simple implementation using the address as a key for the application
 * and a map to hold all the chat logs
 */

// Modules
var express = require("express");
var cors = require('cors');

// OpenAI Chat Session Manager
const { initializeChatSession, generateResponse } = require('./chat.js');

// Start the Express Server
var app = express();
app.use(express.json());

// Enable Cross Origin Resource Sharing
// Nebula Labs Trauma Moment
app.use(cors());
app.options('*', cors());

// Chat endpoint
app.get("/chat", async (req, res) => {
    const { address, input } = req.query;
    try {
        const response = await generateResponse(address, input);
        res.json(response);
    }
    catch (err) {
        console.log(err)
        res.status(500).json('yikes!')
    }
});

// Initialize Chat Session
app.get("/new", async (req, res) => {
    const { address } = req.query;
    try {
        const response = await initializeChatSession(address);
        res.json(response);
    }
    catch (err) {
        console.log(err)
        res.status(500).json(`Whoops! We can't process that right now! Please try again later, or maybe ask another question :)`)
    }
});

// Start the server
app.listen(3000, () => {
    console.log("Server running on port 3000");
});
app.timeout = 60000;

