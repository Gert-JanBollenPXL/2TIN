import runCmd from './runCommand.js';

const getVpcInfo = async (name) => {
    const cmd = 'aws ec2 describe-vpcs --region us-east-1';
    const output = await runCmd(cmd);

    const vpcs = output.Vpcs;
    const foundVpc = vpcs.find(vpc => vpc.Tags?.some(tag => tag.Value === name));
        if(foundVpc) {
            return foundVpc;
        }else {
            return "vpc not found";
        }

};

export { getVpcInfo };