Now export those values as variables before continuing:

```bash
export PRIV_VPC=vpc-0eef4d7687dd46c95
export PRIV_SUBNET=subnet-0da7de65f3a8f5863
export PRIV_RT=rtb-05dcf57044cce97ee
export PRIV_EC2=i-0005cbedc1b019a1e
export PRIV_CIDR=172.31.0.0/16
```

Now continue with creating the public VPC.

## Create Public VPC

```bash
PUB_VPC=$(aws ec2 create-vpc \
  --cidr-block 10.20.0.0/16 \
  --query "Vpc.VpcId" \
  --output text)

echo $PUB_VPC
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

Then create subnet:

```bash
PUB_SUBNET=$(aws ec2 create-subnet \
  --vpc-id $PUB_VPC \
  --cidr-block 10.20.1.0/24 \
  --availability-zone us-east-1a \
  --query "Subnet.SubnetId" \
  --output text)

echo $PUB_SUBNET
```

Tag subnet:

```bash
aws ec2 create-tags \
  --resources $PUB_SUBNET \
  --tags Key=Name,Value=datacenter-pub-subnet
```

Enable public IPs:

```bash
aws ec2 modify-subnet-attribute \
  --subnet-id $PUB_SUBNET \
  --map-public-ip-on-launch
```

Then create route table:

```bash
PUB_RT=$(aws ec2 create-route-table \
  --vpc-id $PUB_VPC \
  --query "RouteTable.RouteTableId" \
  --output text)

echo $PUB_RT
```

Tag it:

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

Then continue with Internet Gateway creation.
