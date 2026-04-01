import { getLoadbalancerByName } from './cli/loadbalancer.js';

const grade = async () => {
    const loadbalancer = await getLoadbalancerByName('pe-alb');
    const publicDns = loadbalancer.DNSName;
    const response = await fetch(`http://${publicDns}/api/courses`, { signal: AbortSignal.timeout(30000) });
    const data = await response.json();

    console.log((data.length == 3 && data[0].course_name) ? "correct" : data);
}


grade();