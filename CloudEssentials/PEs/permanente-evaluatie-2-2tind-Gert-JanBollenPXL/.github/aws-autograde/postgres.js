import {getRDSInfoByName} from './cli/database.js';

const grade = async () => {
    const rdsInstance = await getRDSInfoByName('pe-db');

    const isPrivate = rdsInstance.PubliclyAccessible == true ? false : true;
    const instanceClass = rdsInstance.DBInstanceClass == 'db.t3.micro' ? true : false;
    const masterUsername = rdsInstance.MasterUsername == 'postgres' ? true : false;
    const dbName = rdsInstance.DBName == 'pxl' ? true : false;
    console.log((isPrivate && instanceClass && masterUsername && dbName) ? "correct" : rdsInstance);

}

grade();