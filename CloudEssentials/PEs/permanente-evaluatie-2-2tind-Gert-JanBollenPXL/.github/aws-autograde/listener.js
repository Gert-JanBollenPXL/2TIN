import { getLoadbalancerByName, getListenerByLoadbalancerArn, getTargetGroupByLoadBalancerArn, getTargetsByTargetGroupArn } from "./cli/loadbalancer.js";

const grade = async () => {
    const loadbalancer = await getLoadbalancerByName('pe-alb');
    const listener = await getListenerByLoadbalancerArn(loadbalancer.LoadBalancerArn);
    const targetGroup = await getTargetGroupByLoadBalancerArn(loadbalancer.LoadBalancerArn);
    const targets = await getTargetsByTargetGroupArn(targetGroup.TargetGroupArn);

    const isListenerHttp = listener.Protocol == 'HTTP' ? true : false;
    const isListenerPort80 = listener.Port == 80 ? true : false;
    const isTargetGroupHttp = targetGroup.Protocol == 'HTTP' ? true : false;
    const hasTargets = targets.length > 0 ? true : false;

    console.log((isListenerHttp && isListenerPort80 && isTargetGroupHttp && hasTargets) ? "correct" : JSON.stringify(listener) + "\n\n" + JSON.stringify(targetGroup) + "\n\n" + JSON.stringify(targets));

}

grade();