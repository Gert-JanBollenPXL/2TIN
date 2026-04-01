import { getEc2InfoByName } from "./cli/ec2.js";

const grade = async () => {
    const ec2Instance = await getEc2InfoByName('pxl-api');

    const publicIP = ec2Instance.PublicIpAddress;

    const response = await fetch(`http://${publicIP}/api/courses`);
    const data = await response.json();

    console.log((data.length == 3 && data[0].course_name) ? "correct" : data);
}

grade();