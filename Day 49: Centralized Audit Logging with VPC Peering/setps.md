Here’s a complete step-by-step solution using AWS CLI from the `aws-client` host.

## 1. Configure AWS CLI

Run:

```bash
aws configure
```

Use credentials from:

```bash
showcreds
```

Set:

```text
Region: us-east-1
Output: json
```

---

# 2. Get Existing Private VPC Information

```bash
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=datacenter-priv-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text
```

Save output:

```bash
PRIV_VPC=vpc-xxxxxxxx
```

Get private subnet:

```bash
aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=datacenter-priv-subnet" \
  --query "Subnets[0].SubnetId" \
  --output text
```

```bash
PRIV_SUBNET=subnet-xxxxxxxx
```

Get route table:

```bash
aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=datacenter-priv-rt" \
  --query "RouteTables[0].RouteTableId" \
  --output text
```

```bash
PRIV_RT=rtb-xxxxxxxx
```

Get private instance:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-priv-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text
```

```bash
PRIV_EC2=i-xxxxxxxx
```

Get private VPC CIDR:

```bash
aws ec2 describe-vpcs \
  --vpc-ids $PRIV_VPC \
  --query "Vpcs[0].CidrBlock" \
  --output text
```

```bash
PRIV_CIDR=10.x.x.x/16
```

---

# 3. Create Public VPC

```bash
PUB_VPC=$(aws ec2 create-vpc \
  --cidr-block 10.20.0.0/16 \
  --query "Vpc.VpcId" \
  --output text)
```

Tag it:

```bash
aws ec2 create-tags \
  --resources $PUB_VPC \
  --tags Key=Name,Value=datacenter-pub-vpc
```

Enable DNS:

```bash
aws ec2 modify-vpc-attribute \
  --vpc-id $PUB_VPC \
  --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
  --vpc-id $PUB_VPC \
  --enable-dns-hostnames "{\"Value\":true}"
```

---

# 4. Create Public Subnet

```bash
PUB_SUBNET=$(aws ec2 create-subnet \
  --vpc-id $PUB_VPC \
  --cidr-block 10.20.1.0/24 \
  --availability-zone us-east-1a \
  --query "Subnet.SubnetId" \
  --output text)
```

Tag:

```bash
aws ec2 create-tags \
  --resources $PUB_SUBNET \
  --tags Key=Name,Value=datacenter-pub-subnet
```

Enable public IP assignment:

```bash
aws ec2 modify-subnet-attribute \
  --subnet-id $PUB_SUBNET \
  --map-public-ip-on-launch
```

---

# 5. Create Route Table

```bash
PUB_RT=$(aws ec2 create-route-table \
  --vpc-id $PUB_VPC \
  --query "RouteTable.RouteTableId" \
  --output text)
```

Tag:

```bash
aws ec2 create-tags \
  --resources $PUB_RT \
  --tags Key=Name,Value=datacenter-pub-rt
```

Associate subnet:

```bash
aws ec2 associate-route-table \
  --subnet-id $PUB_SUBNET \
  --route-table-id $PUB_RT
```

---

# 6. Create Internet Gateway

```bash
IGW=$(aws ec2 create-internet-gateway \
  --query "InternetGateway.InternetGatewayId" \
  --output text)
```

Tag:

```bash
aws ec2 create-tags \
  --resources $IGW \
  --tags Key=Name,Value=datacenter-pub-igw
```

Attach:

```bash
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW \
  --vpc-id $PUB_VPC
```

Add route:

```bash
aws ec2 create-route \
  --route-table-id $PUB_RT \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW
```

---

# 7. Create Security Group

```bash
PUB_SG=$(aws ec2 create-security-group \
  --group-name datacenter-pub-sg \
  --description "Public SG" \
  --vpc-id $PUB_VPC \
  --query "GroupId" \
  --output text)
```

Allow SSH:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id $PUB_SG \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

---

# 8. Launch Public EC2

Get Ubuntu AMI:

```bash
AMI=$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id \
  --query "Parameters[0].Value" \
  --output text)
```

Launch instance:

```bash
PUB_EC2=$(aws ec2 run-instances \
  --image-id $AMI \
  --instance-type t2.micro \
  --key-name datacenter-key \
  --subnet-id $PUB_SUBNET \
  --security-group-ids $PUB_SG \
  --query "Instances[0].InstanceId" \
  --output text)
```

Tag:

```bash
aws ec2 create-tags \
  --resources $PUB_EC2 \
  --tags Key=Name,Value=datacenter-pub-ec2
```

---

# 9. Create S3 Bucket

```bash
aws s3api create-bucket \
  --bucket datacenter-s3-logs-20934 \
  --region us-east-1
```

Block public access:

```bash
aws s3api put-public-access-block \
  --bucket datacenter-s3-logs-20934 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

---

# 10. Create IAM Role

Create trust policy:

```bash
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

Create role:

```bash
aws iam create-role \
  --role-name datacenter-s3-role \
  --assume-role-policy-document file://trust-policy.json
```

Create permission policy:

```bash
cat > s3-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::datacenter-s3-logs-20934/*"
    }
  ]
}
EOF
```

Attach inline policy:

```bash
aws iam put-role-policy \
  --role-name datacenter-s3-role \
  --policy-name datacenter-s3-put \
  --policy-document file://s3-policy.json
```

Create instance profile:

```bash
aws iam create-instance-profile \
  --instance-profile-name datacenter-s3-profile
```

Attach role:

```bash
aws iam add-role-to-instance-profile \
  --instance-profile-name datacenter-s3-profile \
  --role-name datacenter-s3-role
```

Wait 20 seconds.

Attach profile to EC2:

```bash
aws ec2 associate-iam-instance-profile \
  --instance-id $PUB_EC2 \
  --iam-instance-profile Name=datacenter-s3-profile
```

---

# 11. Create VPC Peering

```bash
PEER=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $PRIV_VPC \
  --peer-vpc-id $PUB_VPC \
  --query "VpcPeeringConnection.VpcPeeringConnectionId" \
  --output text)
```

Accept:

```bash
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $PEER
```

Get public CIDR:

```bash
PUB_CIDR=$(aws ec2 describe-vpcs \
  --vpc-ids $PUB_VPC \
  --query "Vpcs[0].CidrBlock" \
  --output text)
```

Add routes:

```bash
aws ec2 create-route \
  --route-table-id $PRIV_RT \
  --destination-cidr-block $PUB_CIDR \
  --vpc-peering-connection-id $PEER
```

```bash
aws ec2 create-route \
  --route-table-id $PUB_RT \
  --destination-cidr-block $PRIV_CIDR \
  --vpc-peering-connection-id $PEER
```

---

# 12. Get Public Instance IP

```bash
PUB_IP=$(aws ec2 describe-instances \
  --instance-ids $PUB_EC2 \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)
```

---

# 13. SSH to Public Instance

```bash
chmod 400 /root/.ssh/datacenter-key.pem
```

```bash
ssh -i /root/.ssh/datacenter-key.pem ubuntu@$PUB_IP
```

Install AWS CLI:

```bash
sudo apt update
sudo apt install awscli -y
```

Create upload script:

```bash
sudo bash -c 'cat > /usr/local/bin/upload-to-s3.sh <<EOF
#!/bin/bash
aws s3 cp /tmp/boots.log s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
EOF'
```

```bash
sudo chmod +x /usr/local/bin/upload-to-s3.sh
```

Cron job:

```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/upload-to-s3.sh") | crontab -
```

Exit.

---

# 14. Configure Private Instance

Get private IP:

```bash
PRIV_IP=$(aws ec2 describe-instances \
  --instance-ids $PRIV_EC2 \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text)
```

SSH:

```bash
ssh -i /root/.ssh/datacenter-key.pem ubuntu@$PRIV_IP
```

Copy key:

```bash
mkdir -p ~/.ssh
```

Create script:

```bash
cat > /home/ubuntu/send-log.sh <<EOF
#!/bin/bash
scp -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@$PUB_IP:/tmp/boots.log
EOF
```

```bash
chmod +x /home/ubuntu/send-log.sh
```

Cron:

```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/send-log.sh") | crontab -
```

---

# 15. Verify

After a few minutes:

```bash
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```

Expected:

```text
boots.log
```
