import { getApiGatewayByName, getGatewayStages } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');  
    const stages = await getGatewayStages(apiGateway.id);

    const hasStageDev = stages.find(stage => stage.stageName === 'dev') ? true : false;


    console.log((hasStageDev) ? 'correct' : JSON.stringify(apiGateway) + "\n\n" + JSON.stringify(stages));
}

grade();