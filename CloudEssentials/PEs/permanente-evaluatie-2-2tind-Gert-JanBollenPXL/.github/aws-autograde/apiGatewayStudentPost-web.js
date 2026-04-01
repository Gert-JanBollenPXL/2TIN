import { getApiGatewayByName } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');    
    const gatewayURL = "https://" + apiGateway.id + ".execute-api.us-east-1.amazonaws.com/dev";

    const response = await fetch(`${gatewayURL}/student`, { 
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            id: '123456798abc',
            name: 'Ben Lambrechts',
            class: '3AONX'
        }),
        signal: AbortSignal.timeout(30000) 
    });
    let data = await response.json();
    data = JSON.stringify(data);
    
    const bodyContainsClass = (data.includes("3AONX")) ? true : false;
    const getResponse = await fetch(`${gatewayURL}/student`, { signal: AbortSignal.timeout(30000) });
    let getData = await getResponse.json();
    getData = JSON.stringify(getData);
    
    const HasNewRecordAdded = (getData.includes("Ben Lambrechts")) ? true : false;

    console.log((bodyContainsClass && HasNewRecordAdded) ? "correct" : getData);


}

grade();