import { getApiGatewayByName } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');  
    const gatewayURL = "https://" + apiGateway.id + ".execute-api.us-east-1.amazonaws.com/dev";

    const response = await fetch(`${gatewayURL}/student`, { signal: AbortSignal.timeout(30000) });
    let data = await response.json();
    data = JSON.stringify(data);

    
    const bodyContainsClass = (data.includes("class") || data.includes("[]")) ? true : false;

    console.log((bodyContainsClass) ? "correct" : data);


}

grade();