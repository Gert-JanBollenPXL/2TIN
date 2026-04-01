import runCmd from './runCommand.js';
import fs from 'fs';

const getLambdaByName = async (lambdaName) => {
    const cmd = `aws lambda list-functions`;
    const output = await runCmd(cmd);
    const lambdas = output.Functions;
    const foundLambda = lambdas.find(lambda => lambda.FunctionName === lambdaName);
    if(foundLambda) {
        return foundLambda;
    }else {
        return "lambda function not found";
    }
}

const invokeLambda = async (lambdaName, payload) => {
    const cmd = `aws lambda invoke --function-name ${lambdaName} --payload ${payload} output.json`;
    const output = await runCmd(cmd);
    
    const data = fs.readFileSync('output.json');
    const parsedData = JSON.parse(data);

    return parsedData;
}

export { 
    getLambdaByName,
    invokeLambda
};