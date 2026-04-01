# Oplossing A
aanmaken van vpc:
![vpc](/images/vpc-screenshot.png)

aanmaken van routetable:
![rtb](/images/rtb-screenshot-2.png)


Bewijs routes in routetable:
![screenshot rtb](/images/rtb-screenshot.png)

Gebruikt commando CLI:
```
aws s3 ....
```

Output commando:
![screenshot output comando](/images/cli-screenshot.png)

# Oplossing B

aanmaken VPC:
![vpc](/images/image.png)

# Oplossing C

aanmaken subnets:
![vpc](/images/image-1.png)
![subnet1](/images/image-2.png)
![subnet2](/images/image-3.png)
![auto-assign-ip](/images/image-4.png)

# Oplossing D

creating IGW and attaching to VPC
![create-igw](/images/image-6.png)
![igw-attached](/images/image-5.png)

creating route table etc
![create-rtb](/images/image-7.png)

adding route to 0.0.0./0 and adding to IGW
![adding-route](/images/image-8.png)

adding route table to subnets
![adding-rtb-to-subnets](/images/image-9.png)

# Oplossing E

adding security group and inbound rules
![secgroup-and-inbound-rules](/images/image-10.png)

# Oplossing F

creating key pair
![key-pair](/images/image-11.png)

# Oplossing G

ec2-prac-1:
![creating-ec2](/images/image-12.png)
![instanceType-keypair](/images/image-13.png)
![vpc-subnet-secgroup](/images/image-14.png)
![userdata](/images/image-15.png)

ec2-prac-2:
![creating-ec2](/images/image-16.png)
![instanceType-keypair](/images/image-17.png)
![vpc-subnet-secgroup](/images/image-18.png)
![userdata](/images/image-19.png)

# Oplossing H

creating bucket:
![create-bucket](/images/image-20.png)
uploading index.html:
![uploading-website](/images/image-21.png)
enable static website hosting:
![static-website](/images/image-22.png)
allow access:
![access](/images/image-23.png)
set bucket policy:
![bucket-policy](/images/image-24.png)
see bucket-policy.json for the file used
website screenshot:
![website](/images/image-25.png)
