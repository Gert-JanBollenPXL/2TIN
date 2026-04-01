import runCmd from './runCommand.js';

const getRDSInfoByName = async (name) => {
    const cmd = 'aws rds describe-db-instances';
    const output = await runCmd(cmd);
    const instances = output.DBInstances;
    const foundInstance = instances.find(instance => instance.DBInstanceIdentifier === name);
    if(foundInstance) {
        return foundInstance;
    }else {
        return "database instance not found";
    }
}   

export {
    getRDSInfoByName
};