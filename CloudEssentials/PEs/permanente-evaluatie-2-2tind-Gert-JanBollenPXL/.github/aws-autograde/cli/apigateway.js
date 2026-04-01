import runCmd from './runCommand.js';

const getApiGatewayByName = async (name) => {
    const cmd = 'aws apigateway get-rest-apis';
    const output = await runCmd(cmd);
    const apis = output.items;
    const foundApi = apis.find(api => api.name === name);
    if(foundApi) {
        return foundApi;
    }else {
        return "api not found";
    }
};

const getGatewayStages = async (apiId) => {
    if(!apiId){
        return "apiId not found";
    }
    const cmd = `aws apigateway get-stages --rest-api-id ${apiId}`;
    const output = await runCmd(cmd);
    const stages = output.item;
    if(stages.length > 0) {
        return stages;
    }else {
        return "stages not found";
    }
}

const getResourceInfo = async (apiId) => {
    if(!apiId){
        return "apiId not found";
    }
    const cmd = `aws apigateway get-resources --rest-api-id ${apiId}`;
    const output = await runCmd(cmd);
    const resources = output.items;
    if(resources.length > 0) {
        return resources;
    }else {
        return "resources not found";
    }
}

const getIntegration = async (apiId, resourceId, httpMethod) => {
    if(!apiId || !resourceId || !httpMethod){
        return "apiId, resourceId or httpMethod not found";
    }
    const cmd = `aws apigateway get-integration --rest-api-id ${apiId} --resource-id ${resourceId} --http-method ${httpMethod}`;
    const output = await runCmd(cmd);
    return output;
}


export {
    getApiGatewayByName,
    getGatewayStages,
    getResourceInfo,
    getIntegration
};