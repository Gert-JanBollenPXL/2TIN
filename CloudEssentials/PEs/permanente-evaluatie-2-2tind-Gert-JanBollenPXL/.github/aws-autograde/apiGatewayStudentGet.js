import { getApiGatewayByName, getGatewayStages, getResourceInfo, getIntegration } from "./cli/apigateway.js";


const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');    
    const resources = await getResourceInfo(apiGateway.id);
    
    const resourceStudent =  getResourceByName(resources, '/student');
    const studentIntegration = await getIntegration(apiGateway.id, resourceStudent.id, 'GET');

    const studentLambdaUri = studentIntegration.uri.includes('function:getStudents');
    const typeIsAWS = studentIntegration.type === 'AWS_PROXY' || studentIntegration.type === 'AWS';


    console.log((studentLambdaUri && typeIsAWS) ? 'correct' : JSON.stringify(resources) + "\n\n" + JSON.stringify(studentIntegration));
}

const getResourceByName = (resources, name) => {
    return resources.find(resource => resource.path === name);
}

grade();