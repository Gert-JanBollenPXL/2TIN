import { getApiGatewayByName, getGatewayStages, getResourceInfo, getIntegration } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');   
    const stages = await getGatewayStages(apiGateway.id);
    const resources = await getResourceInfo(apiGateway.id);
    
    const resourceHash =  getResourceByName(resources, '/hash');
    const hashIntegration = await getIntegration(apiGateway.id, resourceHash.id, 'GET');

    const hasStageDev = stages.find(stage => stage.stageName === 'dev') ? true : false;
    const hashHttpIntegration = hashIntegration.type === 'HTTP' || hashIntegration.type === 'HTTP_PROXY';
    const hashIntegrationUriC = hashIntegration.uri.includes('api/check');

    console.log((hasStageDev && hashHttpIntegration && hashIntegrationUriC) ? 'correct' : JSON.stringify(resources) + "\n\n" + JSON.stringify(hashIntegration));
}

const getResourceByName = (resources, name) => {
    return resources.find(resource => resource.path === name);
}

grade();