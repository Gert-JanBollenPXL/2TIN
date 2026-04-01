import { getLambdaByName, invokeLambda } from "./cli/lambda.js";


const grade = async () => {
    const lambda = await getLambdaByName('getStudents');

    const response = await invokeLambda('getStudents', JSON.stringify({}));

    const RoleContainsLabrole = lambda.Role.includes('LabRole') ? true : false;
    const response200 = response.statusCode == 200 ? true : false;

    if(typeof response.body  === 'string'){
        response.body = JSON.parse(response.body);
    }

    const responseBodyIsArray = Array.isArray(response.body) ? true : false;

    console.log((RoleContainsLabrole && response200 && responseBodyIsArray) ? "correct" : JSON.stringify(lambda) + "\n\n" + JSON.stringify(response));
}

grade();