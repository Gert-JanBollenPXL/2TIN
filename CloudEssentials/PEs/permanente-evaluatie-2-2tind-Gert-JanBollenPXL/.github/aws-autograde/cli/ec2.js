import runCmd from './runCommand.js';

const getEc2InfoByName = async (name) => {
    const cmd = 'aws ec2 describe-instances';
    const output = await runCmd(cmd);
    const instances = output.Reservations.flatMap(reservation => reservation.Instances);
    const foundInstance = instances.find(instance => instance.Tags?.some(tag => tag.Value === name));
    if(foundInstance) {
        return foundInstance;
    }else {
        return "instance not found";
    }
};

const getKeyPairInfoByName = async (name) => {
    const cmd = 'aws ec2 describe-key-pairs';
    const output = await runCmd(cmd);
    const keyPairs = output.KeyPairs;
    const foundKeyPair = keyPairs.find(keyPair => keyPair.KeyName === name);
    if(foundKeyPair) {
        return foundKeyPair;
    }else {
        return "key pair not found";
    }
};

const getEc2AttributesByInstanceId = async (instanceId) => {
    if(!instanceId){
        return "instanceId not found";
    }
    const cmd = `aws ec2 describe-instances --instance-ids ${instanceId}`;
    const output = await runCmd(cmd);
    const instance = output.Reservations.flatMap(reservation => reservation.Instances);
    if(instance.length > 0) {
        return instance[0];
    }else {
        return "instance not found";
    }
}

const getSecruityGroupByName = async (name) => {
    const cmd = 'aws ec2 describe-security-groups';
    const output = await runCmd(cmd);
    const securityGroups = output.SecurityGroups;
    const foundSecurityGroup = securityGroups.find(securityGroup => securityGroup.GroupName === name);
    if(foundSecurityGroup) {
        return foundSecurityGroup;
    }else{
        return "security group not found";
    }
    
}

const getSecurityGroupById = async (id) => {
    const cmd = `aws ec2 describe-security-groups --group-ids ${id}`;
    const output = await runCmd(cmd);
    const securityGroups = output.SecurityGroups;
    if(securityGroups.length > 0) {
        return securityGroups[0];
    }else {
        return "security group not found";
    }
}

const getLoadbalancerInfoByName = async (name) => {
    const cmd = 'aws elbv2 describe-load-balancers';
    const output = await runCmd(cmd);
    const loadbalancers = output.LoadBalancers;
    const foundLoadbalancer = loadbalancers.find(loadbalancer => loadbalancer.LoadBalancerName === name);
    if(foundLoadbalancer) {
        return foundLoadbalancer;
    }else {
        return "loadbalancer not found";
    }
};

const getListenerByLoadbalancerArn = async (arn) => {
    if(!arn){
        return "arn not found";
    }
    const cmd = `aws elbv2 describe-listeners --load-balancer-arn ${arn}`;
    const output = await runCmd(cmd);
    const listeners = output.Listeners;
    if(listeners.length > 0) {
        return listeners[0];
    }else {
        return "listener not found";
    }
}

const getTargetGroupByLoadBalancerArn = async (arn) => {
    if(!arn){
        return "arn not found";
    }
    const cmd = `aws elbv2 describe-target-groups --load-balancer-arn ${arn}`;
    const output = await runCmd(cmd);
    const targetGroups = output.TargetGroups;
    if(targetGroups.length > 0) {
        return targetGroups[0];
    }else {
        return "target group not found";
    }
}

const getTargetsByTargetGroupArn = async (arn) => {
    if(!arn){
        return "arn not found";
    }
    const cmd = `aws elbv2 describe-target-health --target-group-arn ${arn}`;
    const output = await runCmd(cmd);
    const targets = output.TargetHealthDescriptions;
    if(targets.length > 0) {
        return targets;
    }else {
        return "targets not found";
    }
}



export { getEc2InfoByName, getSecurityGroupById, getKeyPairInfoByName, getSecruityGroupByName, getEc2AttributesByInstanceId, getLoadbalancerInfoByName, getListenerByLoadbalancerArn, getTargetGroupByLoadBalancerArn, getTargetsByTargetGroupArn };