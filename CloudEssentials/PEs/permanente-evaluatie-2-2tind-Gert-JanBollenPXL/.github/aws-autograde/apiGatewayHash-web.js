import { getApiGatewayByName } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');   
    const gatewayURL = "https://" + apiGateway.id + ".execute-api.us-east-1.amazonaws.com/dev";

    const response = await fetch(`${gatewayURL}/hash`, { signal: AbortSignal.timeout(30000) });
    const data = await response.json();
    console.log((data.md5Hash) ? "correct" : data);

}

grade();