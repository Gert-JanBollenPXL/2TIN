import { getSecurityGroupById } from './cli/ec2.js';
import { getLoadbalancerByName } from './cli/loadbalancer.js';

const grade = async () => {
    const loadbalancer = await getLoadbalancerByName('pe-alb');
    const securityGroupid = loadbalancer.SecurityGroups[0];
    const securityGroupData = await getSecurityGroupById(securityGroupid);

    const isApplication = loadbalancer.Type == 'application' ? true : false;
    const isInternetFacing = loadbalancer.Scheme == 'internet-facing' ? true : false;
    const hasMultipleAzs = loadbalancer.AvailabilityZones.length > 1 ? true : false;

    const inboundRules = securityGroupData.IpPermissions;
    const hasPort80 = inboundRules.find(rule => rule.FromPort == 80) ? true : false;
    
    console.log((isApplication && isInternetFacing && hasMultipleAzs && hasPort80) ? "correct" : loadbalancer);
}

grade();