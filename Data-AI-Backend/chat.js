/**
 * 
 */

// Modules
const OpenAI = require('openai');
const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();

const { getFunctionData } = require('./data-functions.js');

// Good dev moment
const OPEN_AI_KEY = process.env.OPEN_AI_KEY
const RAPID_API_KEY = process.env.RAPID_API_KEY

// Map to keep track of chat sessions
const chatSessionMap = new Map();

// Map to keep track of data for specific houses
const houseDataMap = new Map();

// Functions available to GPT when computing responses
const customDataFunctions = [
    {
        name: "getHouseData",
        description: "Get general data associated with the house in context",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getSurroundingSchoolData",
        description: "Get the schools within the local area for the context house with the distances to each school",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getNeighborhoodData",
        description: "Get the name of the neighborhood this house is within",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getPollenData",
        description: "Get the local pollen data around the context house",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getSolarData",
        description: "Using the google solar API, it finds the best possible implmentation for a solar panel array and green energy implementation",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getAirData",
        description: "Get the local air data around the context house",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getSurroundingPropertyData",
        description: "Get other houses that are surrounding the context house",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getCrimeData",
        description: "Get the crime data within the zip code of the context house",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    },
    {
        name: "getPastEvaluationData",
        description: "Get the past value evaluations of the context house",
        parameters: {
            type: "object",
            properties: {},
            required: [],
        },
    }
]

// Initiate Chat Bot
const open_ai_session = new OpenAI({ apiKey: OPEN_AI_KEY });

module.exports.generateResponse = async (address, userMessage) => {
    console.log(`<!> Starting GPT Chat call for '${address}'`)

    // Get the current conversation
    let conversation = chatSessionMap.get(address)

    if(!conversation){
        await initializeChatSession(address)
        conversation = chatSessionMap.get(address)
    }

    // Add user message to the conversation
    conversation.push({ role: 'user', content: userMessage });

    // Make an API call with the conversation
    const response = await open_ai_session.chat.completions.create({
        model: 'gpt-3.5-turbo-16k',
        messages: conversation,
        functions: customDataFunctions
    });

    // Extract the assistant's reply
    let assistantReply = response.choices[0].message

    if (assistantReply.function_call) {

        // Function the agent needs data from
        const requestedFunction = assistantReply.function_call.name;

        // Get house data
        const houseData = houseDataMap.get(address)

        // Get the data from the function
        const dataToUse = await getFunctionData(requestedFunction,houseData)

        // Build the function message
        const functionMessage = {
            role: "function",
            name: requestedFunction,
            content: JSON.stringify(dataToUse)
        };

        // Add function message to the conversation
        conversation.push(functionMessage);

        // Make an API call with the updated conversation
        const responseUsingFunction = await open_ai_session.chat.completions.create({
            model: 'gpt-3.5-turbo-16k',
            messages: conversation
        });

        // Extract the assistant's reply
        assistantReply = responseUsingFunction.choices[0].message
    }

    // Assistant message content
    const content = assistantReply.content

    // Add assistant message to the conversation
    conversation.push({ role: 'assistant', content: content });

    // Update the conversation record in the map
    chatSessionMap.set(address, conversation)

    console.log(`<!> Ending GPT Chat call for '${address}'`)

    // Return the assistant's reply
    return content;
}

async function initializeChatSession(address) {

    console.log(`<!> Initializing a new chat session for the address '${address}'!`)

    // Place the session in the tracking 
    const systemPrompt = `You are a vittual real estate agent that knows all about the house
    the user is talking about. Act as a agent and answer their questions using the data
    you have access to while also using domain knowledge related to the location of the house.`
    chatSessionMap.set(address, [{ role: "system", content: systemPrompt }])

    // Get the house data
    const houseData = await getHouseData(address)

    houseDataMap.set(address, houseData)

    return houseData
}

module.exports.initializeChatSession = initializeChatSession

async function getZillowId(address) {

    const options = {
        method: 'GET',
        url: 'https://zillow69.p.rapidapi.com/search',
        params: {
            location: address
        },
        headers: {
            'X-RapidAPI-Key': RAPID_API_KEY,
            'X-RapidAPI-Host': 'zillow69.p.rapidapi.com'
        }
    };

    const response = await axios.request(options);
    return response?.data?.zpid
}

async function getHouseData(address) {

    const zillowId = await getZillowId(address)

    if(!zillowId){
        console.log(`<!> There was no Zillow ID associated with the address '${address}'!`)
        return 'no valid data'
    }

    const options = {
        method: 'GET',
        url: 'https://zillow69.p.rapidapi.com/property',
        params: {
            zpid: zillowId
        },
        headers: {
            'X-RapidAPI-Key': RAPID_API_KEY,
            'X-RapidAPI-Host': 'zillow69.p.rapidapi.com'
        }
    };

    const response = await axios.request(options);
    return response.data
}
