
aws-client ~/.ssh ➜  aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=datacenter-priv-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text
vpc-0eef4d7687dd46c95

aws-client ~/.ssh ➜  aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=datacenter-priv-subnet" \
  --query "Subnets[0].SubnetId" \
  --output text
subnet-0da7de65f3a8f5863

aws-client ~/.ssh ➜  aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=datacenter-priv-rt" \
  --query "RouteTables[0].RouteTableId" \
  --output text
rtb-05dcf57044cce97ee

aws-client ~/.ssh ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-priv-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text
i-0005cbedc1b019a1e

aws-client ~/.ssh ➜  aws ec2 describe-vpcs \
  --vpc-ids $PRIV_VPC \
  --query "Vpcs[0].CidrBlock" \
  --output text
172.31.0.0/16

aws-client ~/.ssh ➜  PUB_VPC=$(aws ec2 create-vpc \
  --cidr-block 10.20.0.0/16 \
  --query "Vpc.VpcId" \
  --output text)

echo $PUB_VPC
vpc-02527c50ec2b48476

aws-client ~/.ssh ➜  aws ec2 create-tags \
  --resources $PUB_VPC \
  --tags Key=Name,Value=datacenter-pub-vpc

aws-client ~/.ssh ➜  aws ec2 modify-vpc-attribute \
  --vpc-id $PUB_VPC \
  --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
  --vpc-id $PUB_VPC \
  --enable-dns-hostnames "{\"Value\":true}"

aws-client ~/.ssh ➜  PUB_SUBNET=$(aws ec2 create-subnet \
  --vpc-id $PUB_VPC \
  --cidr-block 10.20.1.0/24 \
  --availability-zone us-east-1a \
  --query "Subnet.SubnetId" \
  --output text)

echo $PUB_SUBNET
subnet-0a65b64bf425647a4

aws-client ~/.ssh ➜  aws ec2 create-tags \
  --resources $PUB_SUBNET \
  --tags Key=Name,Value=datacenter-pub-subnet

aws-client ~/.ssh ➜  aws ec2 modify-subnet-attribute \
  --subnet-id $PUB_SUBNET \
  --map-public-ip-on-launch

aws-client ~/.ssh ➜  PUB_RT=$(aws ec2 create-route-table \
  --vpc-id $PUB_VPC \
  --query "RouteTable.RouteTableId" \
  --output text)

echo $PUB_RT
rtb-06c7ccbebf415b22f

aws-client ~/.ssh ➜  aws ec2 create-tags \
  --resources $PUB_RT \
  --tags Key=Name,Value=datacenter-pub-rt

aws-client ~/.ssh ➜  aws ec2 associate-route-table \
  --subnet-id $PUB_SUBNET \
  --route-table-id $PUB_RT
{
    "AssociationId": "rtbassoc-032a30bb0e2916fc0",
    "AssociationState": {
        "State": "associated"
    }
}

aws-client ~/.ssh ➜  IGW=$(aws ec2 create-internet-gateway \
  --query "InternetGateway.InternetGatewayId" \
  --output text)

aws-client ~/.ssh ➜  aws ec2 create-tags \
  --resources $IGW \
  --tags Key=Name,Value=datacenter-pub-igw

aws-client ~/.ssh ➜  aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW \
  --vpc-id $PUB_VPC

aws-client ~/.ssh ➜  aws ec2 create-route \
  --route-table-id $PUB_RT \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW
{
    "Return": true
}

aws-client ~/.ssh ➜  PUB_SG=$(aws ec2 create-security-group \
  --group-name datacenter-pub-sg \
  --description "Public SG" \
  --vpc-id $PUB_VPC \
  --query "GroupId" \
  --output text)

aws-client ~/.ssh ➜  aws ec2 authorize-security-group-ingress \
  --group-id $PUB_SG \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0333b406606917324",
            "GroupId": "sg-0fae44dac5edf3cd8",
            "GroupOwnerId": "644306594621",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:644306594621:security-group-rule/sgr-0333b406606917324"
        }
    ]
}

aws-client ~/.ssh ➜  AMI=$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id \
  --query "Parameters[0].Value" \
  --output text)

aws-client ~/.ssh ➜  PUB_EC2=$(aws ec2 run-instances \
  --image-id $AMI \
  --instance-type t2.micro \
  --key-name datacenter-key \
  --subnet-id $PUB_SUBNET \
  --security-group-ids $PUB_SG \
  --query "Instances[0].InstanceId" \
  --output text)

aws-client ~/.ssh ➜  aws ec2 create-tags \
  --resources $PUB_EC2 \
  --tags Key=Name,Value=datacenter-pub-ec2

aws-client ~/.ssh ➜  aws s3api create-bucket \
  --bucket datacenter-s3-logs-20934 \
  --region us-east-1
{
    "Location": "/datacenter-s3-logs-20934",
    "BucketArn": "arn:aws:s3:::datacenter-s3-logs-20934"
}

aws-client ~/.ssh ➜  aws s3api put-public-access-block \
  --bucket datacenter-s3-logs-20934 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws-client ~/.ssh ➜  cat > trust-policy.json <<EOF
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

aws-client ~/.ssh ➜  aws iam create-role \
  --role-name datacenter-s3-role \
  --assume-role-policy-document file://trust-policy.json
{
    "Role": {
        "Path": "/",
        "RoleName": "datacenter-s3-role",
        "RoleId": "AROAZMA5KNM6RIAXTSWAF",
        "Arn": "arn:aws:iam::644306594621:role/datacenter-s3-role",
        "CreateDate": "2026-05-12T05:57:38Z",
        "AssumeRolePolicyDocument": {
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
    }
}

aws-client ~/.ssh ➜  cat > s3-policy.json <<EOF
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

aws-client ~/.ssh ➜  aws iam put-role-policy \
  --role-name datacenter-s3-role \
  --policy-name datacenter-s3-put \
  --policy-document file://s3-policy.json

An error occurred (AccessDenied) when calling the PutRolePolicy operation: User: arn:aws:iam::644306594621:user/kk_labs_user_940531 is not authorized to perform: iam:PutRolePolicy on resource: role datacenter-s3-role because no identity-based policy allows the iam:PutRolePolicy action

aws-client ~/.ssh ✖ cat s3-policy.json
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

aws-client ~/.ssh ➜  aws iam put-role-policy \
  --role-name datacenter-s3-role \
  --policy-name datacenter-s3-put \
  --policy-document file://s3-policy.json

An error occurred (AccessDenied) when calling the PutRolePolicy operation: User: arn:aws:iam::644306594621:user/kk_labs_user_940531 is not authorized to perform: iam:PutRolePolicy on resource: role datacenter-s3-role because no identity-based policy allows the iam:PutRolePolicy action

aws-client ~/.ssh ✖ aws iam attach-role-policy \
  --role-name datacenter-s3-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws-client ~/.ssh ➜  aws iam create-instance-profile \
  --instance-profile-name datacenter-s3-profile
{
    "InstanceProfile": {
        "Path": "/",
        "InstanceProfileName": "datacenter-s3-profile",
        "InstanceProfileId": "AIPAZMA5KNM6S7U5MQQBY",
        "Arn": "arn:aws:iam::644306594621:instance-profile/datacenter-s3-profile",
        "CreateDate": "2026-05-12T05:59:24Z",
        "Roles": []
    }
}

aws-client ~/.ssh ➜  aws iam add-role-to-instance-profile \
  --instance-profile-name datacenter-s3-profile \
  --role-name datacenter-s3-role

aws-client ~/.ssh ➜  aws ec2 associate-iam-instance-profile \
  --instance-id $PUB_EC2 \
  --iam-instance-profile Name=datacenter-s3-profile
{
    "IamInstanceProfileAssociation": {
        "AssociationId": "iip-assoc-06085fedd60af7b3f",
        "InstanceId": "i-0ca7249235ca5b87d",
        "IamInstanceProfile": {
            "Arn": "arn:aws:iam::644306594621:instance-profile/datacenter-s3-profile",
            "Id": "AIPAZMA5KNM6S7U5MQQBY"
        },
        "State": "associating"
    }
}

aws-client ~/.ssh ➜  PEER=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $PRIV_VPC \
  --peer-vpc-id $PUB_VPC \
  --query "VpcPeeringConnection.VpcPeeringConnectionId" \
  --output text)

echo $PEER
Note: AWS CLI version 2, the latest major version of the AWS CLI, is now stable and recommended for general use. For more information, see the AWS CLI version 2 installation instructions at: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help
aws: error: argument --vpc-id: expected one argument


aws-client ~/.ssh ➜  aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $PEER
Note: AWS CLI version 2, the latest major version of the AWS CLI, is now stable and recommended for general use. For more information, see the AWS CLI version 2 installation instructions at: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help
aws: error: argument --vpc-peering-connection-id: expected one argument

aws-client ~/.ssh ✖ echo $PRIV_VPC
echo $PUB_VPC

vpc-02527c50ec2b48476

aws-client ~/.ssh ➜  export PRIV_VPC=vpc-0eef4d7687dd46c95

aws-client ~/.ssh ➜  aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=datacenter-pub-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text
vpc-02527c50ec2b48476

aws-client ~/.ssh ➜  export PUB_VPC=vpc-02527c50ec2b48476

aws-client ~/.ssh ➜  PEER=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $PRIV_VPC \
  --peer-vpc-id $PUB_VPC \
  --query "VpcPeeringConnection.VpcPeeringConnectionId" \
  --output text)

echo $PEER
pcx-0b4d5128a6bb06901

aws-client ~/.ssh ➜  aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $PEER
{
    "VpcPeeringConnection": {
        "AccepterVpcInfo": {
            "CidrBlock": "10.20.0.0/16",
            "CidrBlockSet": [
                {
                    "CidrBlock": "10.20.0.0/16"
                }
            ],
            "OwnerId": "644306594621",
            "PeeringOptions": {
                "AllowDnsResolutionFromRemoteVpc": false,
                "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                "AllowEgressFromLocalVpcToRemoteClassicLink": false
            },
            "VpcId": "vpc-02527c50ec2b48476",
            "Region": "us-east-1"
        },
        "RequesterVpcInfo": {
            "CidrBlock": "10.10.0.0/16",
            "CidrBlockSet": [
                {
                    "CidrBlock": "10.10.0.0/16"
                }
            ],
            "OwnerId": "644306594621",
            "PeeringOptions": {
                "AllowDnsResolutionFromRemoteVpc": false,
                "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                "AllowEgressFromLocalVpcToRemoteClassicLink": false
            },
            "VpcId": "vpc-0eef4d7687dd46c95",
            "Region": "us-east-1"
        },
        "Status": {
            "Code": "provisioning",
            "Message": "Provisioning"
        },
        "Tags": [],
        "VpcPeeringConnectionId": "pcx-0b4d5128a6bb06901"
    }
}

aws-client ~/.ssh ➜  export PRIV_RT=rtb-05dcf57044cce97ee
export PRIV_CIDR=10.10.0.0/16

aws-client ~/.ssh ➜  aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=datacenter-pub-rt" \
  --query "RouteTables[0].RouteTableId" \
  --output text
rtb-06c7ccbebf415b22f

aws-client ~/.ssh ➜  export PUB_RT=rtb-06c7ccbebf415b22f

aws-client ~/.ssh ➜  aws ec2 create-route \
  --route-table-id $PRIV_RT \
  --destination-cidr-block 10.20.0.0/16 \
  --vpc-peering-connection-id $PEER
{
    "Return": true
}

aws-client ~/.ssh ➜  aws ec2 create-route \
  --route-table-id $PUB_RT \
  --destination-cidr-block 10.10.0.0/16 \
  --vpc-peering-connection-id $PEER
{
    "Return": true
}

aws-client ~/.ssh ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-pub-ec2" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
3.83.189.175

aws-client ~/.ssh ➜  chmod 400 /root/.ssh/datacenter-key.pem

aws-client ~/.ssh ➜  ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
The authenticity of host '3.83.189.175 (3.83.189.175)' can't be established.
ECDSA key fingerprint is SHA256:/9Lp+OeF7zqEqGmmS5XzyEfQBhiQmq1d1qeaKWUiaFE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.83.189.175' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1013-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:05:11 UTC 2026

  System load:  0.0               Processes:             106
  Usage of /:   25.0% of 6.71GB   Users logged in:       0
  Memory usage: 21%               IPv4 address for enX0: 10.20.1.118
  Swap usage:   0%

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-20-1-118:~$ sudo apt update
sudo apt install awscli -y
Get:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble InRelease [256 kB]
Get:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:5 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/main amd64 Packages [1401 kB]
Get:6 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/main Translation-en [513 kB]
Get:7 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/main amd64 Components [464 kB]
Get:8 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/main amd64 c-n-f Metadata [30.5 kB]
Get:9 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 Packages [15.0 MB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1668 kB]
Get:11 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/universe Translation-en [5982 kB]
Get:12 http://security.ubuntu.com/ubuntu noble-security/main Translation-en [263 kB]    
Get:13 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [21.9 kB] 
Get:14 http://security.ubuntu.com/ubuntu noble-security/main amd64 c-n-f Metadata [11.0 kB]
Get:15 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [1186 kB]
Get:16 http://security.ubuntu.com/ubuntu noble-security/universe Translation-en [228 kB]
Get:17 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.2 kB]
Get:18 http://security.ubuntu.com/ubuntu noble-security/universe amd64 c-n-f Metadata [23.1 kB]
Get:19 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [2943 kB]
Get:20 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 Components [3871 kB]
Get:21 http://security.ubuntu.com/ubuntu noble-security/restricted Translation-en [685 kB]
Get:22 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Components [212 B]
Get:23 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 c-n-f Metadata [544 B]
Get:24 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [28.8 kB]
Get:25 http://security.ubuntu.com/ubuntu noble-security/multiverse Translation-en [7428 B]
Get:26 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Components [208 B]
Get:27 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 c-n-f Metadata [396 B]
Get:28 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 c-n-f Metadata [301 kB]
Get:29 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/restricted amd64 Packages [93.9 kB]
Get:30 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/restricted Translation-en [18.7 kB]
Get:31 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/restricted amd64 c-n-f Metadata [416 B]
Get:32 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/multiverse amd64 Packages [269 kB]
Get:33 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/multiverse Translation-en [118 kB]
Get:34 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/multiverse amd64 Components [35.0 kB]
Get:35 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble/multiverse amd64 c-n-f Metadata [8328 B]
Get:36 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1969 kB]
Get:37 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/main Translation-en [351 kB]
Get:38 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [177 kB]
Get:39 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/main amd64 c-n-f Metadata [17.1 kB]
Get:40 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [1689 kB]
Get:41 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/universe Translation-en [328 kB]
Get:42 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:43 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/universe amd64 c-n-f Metadata [34.5 kB]
Get:44 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [3124 kB]
Get:45 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/restricted Translation-en [721 kB]
Get:46 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Components [212 B]
Get:47 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/restricted amd64 c-n-f Metadata [480 B]
Get:48 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Packages [44.4 kB]
Get:49 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/multiverse Translation-en [10.7 kB]
Get:50 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:51 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 c-n-f Metadata [656 B]
Get:52 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/main amd64 Packages [40.6 kB]
Get:53 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/main Translation-en [9172 B]
Get:54 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [5740 B]
Get:55 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/main amd64 c-n-f Metadata [368 B]
Get:56 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/universe amd64 Packages [31.0 kB]
Get:57 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/universe Translation-en [18.6 kB]
Get:58 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [10.5 kB]
Get:59 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/universe amd64 c-n-f Metadata [1484 B]
Get:60 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/restricted amd64 Components [212 B]
Get:61 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/restricted amd64 c-n-f Metadata [116 B]
Get:62 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Packages [748 B]
Get:63 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/multiverse Translation-en [340 B]
Get:64 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Components [212 B]
Get:65 http://us-east-1.ec2.archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 c-n-f Metadata [116 B]
Fetched 44.9 MB in 8s (5459 kB/s)                                                       
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
7 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Package awscli is not available, but is referred to by another package.
This may mean that the package is missing, has been obsoleted, or
is only available from another source

E: Package 'awscli' has no installation candidate
ubuntu@ip-10-20-1-118:~$ aws --version
Command 'aws' not found, but can be installed with:
sudo snap install aws-cli  # version 1.45.6, or
sudo apt  install awscli   # version 2.14.6-1
See 'snap info aws-cli' for additional versions.
ubuntu@ip-10-20-1-118:~$ sudo snap install aws-cli
error: This revision of snap "aws-cli" was published using classic confinement and thus
       may perform arbitrary system changes outside of the security sandbox that snaps
       are usually confined to, which may put your system at risk.

       If you understand and want to proceed repeat the command including --classic.
ubuntu@ip-10-20-1-118:~$ sudo snap install aws-cli --classic
aws-cli (v2/stable) 2.34.45 from Amazon Web Services (aws✓) installed
ubuntu@ip-10-20-1-118:~$ aws --version
aws-cli/2.34.45 Python/3.14.4 Linux/6.17.0-1013-aws exe/x86_64.ubuntu.24
ubuntu@ip-10-20-1-118:~$ sudo tee /usr/local/bin/upload-to-s3.sh > /dev/null <<'EOF'
#!/bin/bash
aws s3 cp /tmp/boots.log s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log 
EOF
ubuntu@ip-10-20-1-118:~$ sudo chmod +x /usr/local/bin/upload-to-s3.sh
ubuntu@ip-10-20-1-118:~$ sudo touch /tmp/boots.log
ubuntu@ip-10-20-1-118:~$ sudo /usr/local/bin/upload-to-s3.sh
upload: ../../tmp/boots.log to s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
ubuntu@ip-10-20-1-118:~$ (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/upload-to-s3.sh") | crontab -
ubuntu@ip-10-20-1-118:~$ crontab -l
*/5 * * * * /usr/local/bin/upload-to-s3.sh
ubuntu@ip-10-20-1-118:~$ exit
logout
Connection to 3.83.189.175 closed.

aws-client ~/.ssh ➜  aws ec2 describe-instances \
  --instance-ids $PRIV_EC2 \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text
10.10.1.161

aws-client ~/.ssh ➜  ssh -i /root/.ssh/datacenter-key.pem ubuntu@10.10.1.161
ssh: connect to host 10.10.1.161 port 22: Connection timed out

aws-client ~/.ssh ✖ ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1013-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:11:47 UTC 2026

  System load:  0.09              Processes:             109
  Usage of /:   31.2% of 6.71GB   Users logged in:       0
  Memory usage: 24%               IPv4 address for enX0: 10.20.1.118
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Tue May 12 06:05:12 2026 from 65.108.255.62
ubuntu@ip-10-20-1-118:~$ ssh -i /home/ubuntu/.ssh/datacenter-key.pem ubuntu@10.10.1.161
Warning: Identity file /home/ubuntu/.ssh/datacenter-key.pem not accessible: No such file or directory.
The authenticity of host '10.10.1.161 (10.10.1.161)' can't be established.
ED25519 key fingerprint is SHA256:jYaUn3wyvIcgtKwtkLtMYS578x0WX8pAMWDe1ar45co.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.1.161' (ED25519) to the list of known hosts.
ubuntu@10.10.1.161: Permission denied (publickey).
ubuntu@ip-10-20-1-118:~$ mkdir -p ~/.ssh
ubuntu@ip-10-20-1-118:~$ scp -i /root/.ssh/datacenter-key.pem /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175:/home/ubuntu/.ssh/
scp: stat local "/root/.ssh/datacenter-key.pem": Permission denied
ubuntu@ip-10-20-1-118:~$ exit
logout
Connection to 3.83.189.175 closed.

aws-client ~/.ssh ✖ scp -i /root/.ssh/datacenter-key.pem /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175:/home/ubuntu/.ssh/
datacenter-key.pem                                     100% 1679    15.2KB/s   00:00    

aws-client ~/.ssh ➜  ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1013-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:13:02 UTC 2026

  System load:  0.02              Processes:             108
  Usage of /:   31.2% of 6.71GB   Users logged in:       0
  Memory usage: 24%               IPv4 address for enX0: 10.20.1.118
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Tue May 12 06:11:48 2026 from 65.108.255.62
ubuntu@ip-10-20-1-118:~$ chmod 400 ~/.ssh/datacenter-key.pem
ubuntu@ip-10-20-1-118:~$ ssh -i ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1084-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:13:43 UTC 2026

  System load:  0.0               Processes:             102
  Usage of /:   21.9% of 7.57GB   Users logged in:       0
  Memory usage: 21%               IPv4 address for ens5: 10.10.1.161
  Swap usage:   0%

Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

Enable ESM Infra to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-10-1-161:~$ cat > /home/ubuntu/send-log.sh <<'EOF'
> #!/bin/bash
> scp -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/tmp/boots.log
> EOF
ubuntu@ip-10-10-1-161:~$ chmod +x /home/ubuntu/send-log.sh
ubuntu@ip-10-10-1-161:~$ bash /home/ubuntu/send-log.sh
Warning: Permanently added '10.20.1.118' (ECDSA) to the list of known hosts.
ubuntu@10.20.1.118: Permission denied (publickey).
lost connection
ubuntu@ip-10-10-1-161:~$ (crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/send-log.sh") | crontab -
ubuntu@ip-10-10-1-161:~$ aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/

Command 'aws' not found, but can be installed with:

sudo apt install awscli

ubuntu@ip-10-10-1-161:~$ scp -i ~/.ssh/datacenter-key.pem ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161:/home/ubuntu/.ssh/
Warning: Identity file /home/ubuntu/.ssh/datacenter-key.pem not accessible: No such file or directory.
The authenticity of host '10.10.1.161 (10.10.1.161)' can't be established.
ECDSA key fingerprint is SHA256:GyTxsR0tLRzRKEtJQ+IzO5Ny8hmFDl/XS5lGgy3oqn0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.1.161' (ECDSA) to the list of known hosts.
ubuntu@10.10.1.161: Permission denied (publickey).
lost connection
ubuntu@ip-10-10-1-161:~$ exit
logout
Connection to 10.10.1.161 closed.
ubuntu@ip-10-20-1-118:~$ scp -i ~/.ssh/datacenter-key.pem ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161:/home/ubuntu/.ssh/
datacenter-key.pem                                     100% 1679     3.0MB/s   00:00    
ubuntu@ip-10-20-1-118:~$ ssh -i ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1084-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:15:20 UTC 2026

  System load:  0.0               Processes:             102
  Usage of /:   22.5% of 7.57GB   Users logged in:       0
  Memory usage: 21%               IPv4 address for ens5: 10.10.1.161
  Swap usage:   0%


Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

Enable ESM Infra to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Tue May 12 06:13:43 2026 from 10.20.1.118
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-10-1-161:~$ ssh -i ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1084-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May 12 06:15:20 UTC 2026

  System load:  0.0               Processes:             102
  Usage of /:   22.5% of 7.57GB   Users logged in:       0
  Memory usage: 21%               IPv4 address for ens5: 10.10.1.161
  Swap usage:   0%


Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

Enable ESM Infra to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Tue May 12 06:15:29 2026 from 10.20.1.118
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-10-1-161:~$ chmod 400 ~/.ssh/datacenter-key.pem
ubuntu@ip-10-10-1-161:~$ cat > /home/ubuntu/send-log.sh <<'EOF'
> #!/bin/bash
> scp -i /home/ubuntu/.ssh/datacenter-key.pem -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/tmp/boots.log
> EOF
ubuntu@ip-10-10-1-161:~$ chmod +x /home/ubuntu/send-log.sh
ubuntu@ip-10-10-1-161:~$ bash /home/ubuntu/send-log.sh
scp: /tmp/boots.log: Permission denied
ubuntu@ip-10-10-1-161:~$ aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/

Command 'aws' not found, but can be installed with:

sudo apt install awscli

ubuntu@ip-10-10-1-161:~$ cat > /home/ubuntu/send-log.sh <<'EOF'
> #!/bin/bash
> scp -i /home/ubuntu/.ssh/datacenter-key.pem -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/home/ubuntu/boots.log
> EOF
ubuntu@ip-10-10-1-161:~$ chmod +x /home/ubuntu/send-log.sh
ubuntu@ip-10-10-1-161:~$ bash /home/ubuntu/send-log.sh
boots.log                                              100%   27    43.5KB/s   00:00    
ubuntu@ip-10-10-1-161:~$ exit
logout
Connection to 10.10.1.161 closed.
ubuntu@ip-10-10-1-161:~$ sudo tee /usr/local/bin/upload-to-s3.sh > /dev/null <<'EOF'
> #!/bin/bash
> aws s3 cp /home/ubuntu/boots.log s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
> EOF
ubuntu@ip-10-10-1-161:~$ sudo chmod +x /usr/local/bin/upload-to-s3.sh
ubuntu@ip-10-10-1-161:~$ sudo /usr/local/bin/upload-to-s3.sh
/usr/local/bin/upload-to-s3.sh: line 2: aws: command not found
ubuntu@ip-10-10-1-161:~$ aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/

Command 'aws' not found, but can be installed with:

sudo apt install awscli

ubuntu@ip-10-10-1-161:~$ exit
logout
Connection to 10.10.1.161 closed.
ubuntu@ip-10-20-1-118:~$ sudo /usr/local/bin/upload-to-s3.sh
upload: ../../tmp/boots.log to s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
ubuntu@ip-10-20-1-118:~$ aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
2026-05-12 06:19:09          0 boots.log
ubuntu@ip-10-20-1-118:~$ 
