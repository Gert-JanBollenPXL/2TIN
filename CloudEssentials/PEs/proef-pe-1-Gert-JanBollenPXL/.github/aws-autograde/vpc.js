import {getVpcInfo} from './cli/vpc.js';

const gradeVpc = async () => {
    try {
        const vpc = await getVpcInfo("vpc-pe");
        console.log(vpc.CidrBlock && vpc.CidrBlock == '10.0.0.0/16' ? "correct" : vpc);
    } catch (error) {
        console.log(error);
    }
}

gradeVpc();