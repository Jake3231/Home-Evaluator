/**
 * 
 */

// Modules
const { Client } = require('@googlemaps/google-maps-services-js');
const axios = require('axios');

// Good Dev Moment
const RAPID_API_KEY = process.env.RAPID_API_KEY
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY
const AMBEE_API_KEY = process.env.AMBEE_API_KEY
const dotenv = require('dotenv');
dotenv.config();

// Google maps services client
const client = new Client();

// Map to all available data functions
const dataFunctionMap = new Map()

module.exports.getFunctionData = async (requestedFunction, houseData) => {
   
    // Find the correct data function
    const dataFunction = dataFunctionMap.get(requestedFunction)

    // Get the data
    const data = await dataFunction(houseData)

    if(data && data != 'no data found'){
        console.log(`<!> Data successfully found for the function '${requestedFunction}'!`)
    }
    else{
        console.log(`<!> No data was pulled for the function'${requestedFunction}'!`)
    }

    return data
}

// Get data associated with the house in context
dataFunctionMap.set('getHouseData', async(houseData) => {
    return houseData || 'no data found'
})

// Get the schools in the local area for the context house
dataFunctionMap.set('getSurroundingSchoolData', async(houseData) => {
    return houseData.schools || 'no data found'
})

// Get the name of the neighborhood this house is within
dataFunctionMap.set('getNeighborhoodData', async(houseData) => {

    // Build the address
    const addressParts = houseData.addressParts || houseData.address

    if(!addressParts){
        return 'no data found'
    }
    const streetAddress = addressParts.streetAddress
    const city = addressParts.city
    const state = addressParts.state

    const queryAddress = `${streetAddress}, ${city}, ${state}`

    const response = await client.geocode({
        params: {
            address: queryAddress,
            key: GOOGLE_API_KEY
        }
    })

    const address_components = response?.data?.results[0].address_components
    const neighborhood = address_components?.filter(loc => loc.types.includes('neighborhood'))[0].long_name
    return neighborhood || 'no data found'
})

// Get the local pollen data around the context house
dataFunctionMap.set('getPollenData', async(houseData) => {

    const options = {
        method: 'GET',
        url: `https://api.ambeedata.com/forecast/pollen/by-lat-lng?lat=${houseData.latitude}&lng=${houseData.longitude}`,
        headers: {
            'Content-type': 'application/json',
            'x-api-key': AMBEE_API_KEY
        }
    };

    try {
        const response = await axios.request(options);
        return response.data
    } catch (error) {
        console.error(error);
    }

    return 'no data found'
})

// Get the local solar data around the context house
dataFunctionMap.set('getSolarData', async(houseData) => {
    const options = {
        method: 'GET',
        url: `https://solar.googleapis.com/v1/buildingInsights:findClosest?location.latitude=${houseData.latitude}&location.longitude=${houseData.longitude}&requiredQuality=HIGH&key=${GOOGLE_API_KEY}`,
        headers: {
            'Content-type': 'application/json',
        }
    };

    try {
        const response = await axios.request(options);
        const potential = response.data.solarPotential.financialAnalyses
        potential.sort((a,b) => a.cashPurchaseSavings.paybackYears - b.cashPurchaseSavings.paybackYears)

        return potential[0]
    } catch (error) {
        console.error(error);
    }

    return 'no data found'
})

// Get the local air data around the context house
dataFunctionMap.set('getAirData', async(houseData) => {
    const URL = 'https://airquality.googleapis.com/v1/history:lookup';
    
    const data = {
      hours: 40,
      pageSize: 672,
      pageToken: '',
      location: {
        latitude: houseData.latitude,
        longitude: houseData.longitude,
      },
    };
    
    const response = await axios.post(URL, data, {
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        key: GOOGLE_API_KEY,
      },
    })

    return response?.data || 'no data found'
})

// Get other houses that are surrounding the context house
dataFunctionMap.set('getSurroundingPropertyData', async(houseData) => {
    return houseData.nearbyHomes
})

// Get the crime data within the zip code of the context house
dataFunctionMap.set('getCrimeData', async(houseData) => {

const options = {
  method: 'GET',
  url: 'https://crimescore.p.rapidapi.com/crimescore',
  params: {
    lon: houseData.longitude,
    lat: houseData.latitude
},
  headers: {
    'X-RapidAPI-Key': RAPID_API_KEY,
    'X-RapidAPI-Host': 'crimescore.p.rapidapi.com'
  }
};

try {
	const response = await axios.request(options);
	return response.data
} catch (error) {
	console.error(error);
}

return 'no data was found'
})

// Get the past value evaluations of the context house
dataFunctionMap.set('getPastEvaluationData', async(houseData) => {

    const evalData = houseData?.taxHistory || 'no data was found'
    return evalData
})