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

const getSubnetInfo = async (name) => {
    const cmd = 'aws ec2 describe-subnets';
    const output = await runCmd(cmd);
    const subnets = output.Subnets;
    const foundSubnet = subnets.find(subnet => subnet.Tags?.some(tag => tag.Value === name));
    if(foundSubnet) {
        return foundSubnet;
    }else {
        return "subnet not found";
    }
};

const getInternetGatewayInfo = async (name) => {
    const cmd = 'aws ec2 describe-internet-gateways';
    const output = await runCmd(cmd);
    const igs = output.InternetGateways;
    const foundIg = igs.find(ig => ig.Tags?.some(tag => tag.Value === name));
    if(foundIg) {
        return foundIg;
    }else {
        return "igw not found";
    }
}

const getNatGatewayInfo = async (name) => {
    const cmd = 'aws ec2 describe-nat-gateways';
    const output = await runCmd(cmd);
    const nats = output.NatGateways;
    const foundNat = nats.find(nat => nat.Tags?.some(tag => tag.Value === name));
    if(foundNat) {
        return foundNat;
    }else {
        return "nat not found";
    }
}

const getRouteTableInfo = async (vpcId,igwId) => {
    const cmd = 'aws ec2 describe-route-tables';
    const output = await runCmd(cmd);
    let routeTables = output.RouteTables;
    routeTables = routeTables.filter(routeTable => routeTable.VpcId === vpcId); 
    const foundRouteTable = routeTables.find(routeTable => routeTable.Routes.some(route => route.DestinationCidrBlock === '0.0.0.0/0' && (route.GatewayId && route.GatewayId.includes(igwId))));
    if(foundRouteTable) {
        return foundRouteTable;
    } else {
        return "route table not found or does not have a route to internet gateway";
    }
};

const getRouteTableInfoByName = async (rtbName) => {
    const cmd = 'aws ec2 describe-route-tables';
    const output = await runCmd(cmd);
    const routeTables = output.RouteTables;
    const foundRouteTable = routeTables.find(routeTable => routeTable.Tags?.some(tag => tag.Value === rtbName));
    if (foundRouteTable){
        return foundRouteTable;
    }else{
        return "route table not found";
    }
}

export { getVpcInfo, getSubnetInfo, getInternetGatewayInfo, getNatGatewayInfo, getRouteTableInfo, getRouteTableInfoByName };