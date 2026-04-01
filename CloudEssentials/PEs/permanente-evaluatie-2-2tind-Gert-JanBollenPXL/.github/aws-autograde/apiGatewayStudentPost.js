import { getApiGatewayByName, getGatewayStages, getResourceInfo, getIntegration } from "./cli/apigateway.js";

// Deze test werkt enkel als studenten Lambda proxy integration gebruikt hebben
const grade = async () => {
    const apiGateway = await getApiGatewayByName('pe-gateway-student');     
    const resources = await getResourceInfo(apiGateway.id);
    
    const resourceStudent =  getResourceByName(resources, '/student');
    const studentIntegration = await getIntegration(apiGateway.id, resourceStudent.id, 'POST');

    const studentResourceUri = studentIntegration.uri.includes('function:postStudents');
    const typeIsAWSProxy = studentIntegration.type === 'AWS_PROXY';
    

    console.log((studentResourceUri && typeIsAWSProxy) ? 'correct' : JSON.stringify(resources) + "\n\n" + JSON.stringify(studentIntegration));
}

const getResourceByName = (resources, name) => {
    return resources.find(resource => resource.path === name);
}

grade();