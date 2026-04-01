import runCmd from './runCommand.js';

const getS3ByFilter = async (searchTerm) => {
    const cmd = 'aws s3api list-buckets';
    const output = await runCmd(cmd);
    const buckets = output.Buckets;
    const foundBucket = buckets.find(bucket => bucket.Name.includes(searchTerm));
    if(foundBucket) {
        return foundBucket;
    }else {
        return "bucket not found";
    }
};

const getPublicAccessBlock = async (bucketName) => {
    if(!bucketName) return 'bucket name not found';
    const cmd = `aws s3api get-public-access-block --bucket ${bucketName}`;
    const output = await runCmd(cmd);
    if(output.PublicAccessBlockConfiguration){
        return output.PublicAccessBlockConfiguration;
    }else{
        return "public access block not found";
    }
}

const getBucketPolicy = async (bucketName) => {
    if(!bucketName) return 'bucket name not found';
    try {
        const cmd = `aws s3api get-bucket-policy --bucket ${bucketName}`;
        const output = await runCmd(cmd);
        if(output.Policy){
            return JSON.parse(output.Policy);
        }else {
            return "bucket policy not found";
        }
    } catch (error) {
        return "bucket policy not found";
    }
    
}

export { getS3ByFilter, getBucketPolicy, getPublicAccessBlock };