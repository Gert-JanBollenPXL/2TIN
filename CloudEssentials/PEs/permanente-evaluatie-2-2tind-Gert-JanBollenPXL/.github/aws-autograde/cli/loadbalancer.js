import runCmd from './runCommand.js';

const getLoadbalancerByName = async (name) => {
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

export {
    getLoadbalancerByName,
    getTargetGroupByLoadBalancerArn,
    getListenerByLoadbalancerArn,
    getTargetsByTargetGroupArn
};