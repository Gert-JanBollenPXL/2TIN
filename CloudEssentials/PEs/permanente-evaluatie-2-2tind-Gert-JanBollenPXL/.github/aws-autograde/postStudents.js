import { getLambdaByName, invokeLambda } from "./cli/lambda.js";

// Deze test werkt enkel na implementatie API gateway
// dwz dat de lambda de JSON.Parse() functie moet bevatten op het event.body object
const grade = async () => {
    const lambda = await getLambdaByName('postStudents');
    // payload is base64 encoded
    const payload = "eyJib2R5IjogIntcImlkXCI6IFwiMTIzXCIsIFwibmFtZVwiOiBcIkRyaWVzIFN3aW5uZW5cIiwgXCJjbGFzc1wiOiBcIjFUSU5hXCJ9In0=";
    const response = await invokeLambda('postStudents', payload);

    // check if response.body is a json string
    if(typeof response.body  === 'string'){
        response.body = JSON.parse(response.body);
    }
    const responseContainsId = response.body.id == '123' ? true : false;
    const response200 = response.statusCode == 200 ? true : false;

    console.log((responseContainsId && response200) ? "correct" : response);
}

grade();