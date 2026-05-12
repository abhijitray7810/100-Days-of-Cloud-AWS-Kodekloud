Great — peering is created successfully.

Now export the remaining variables again because your shell lost some earlier.

```bash id="2yhnrm"
export PRIV_RT=rtb-05dcf57044cce97ee
export PRIV_CIDR=10.10.0.0/16
```

Find the public route table:

```bash id="75j2f0"
aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=datacenter-pub-rt" \
  --query "RouteTables[0].RouteTableId" \
  --output text
```

Export it:

Example:

```bash id="g5tslr"
export PUB_RT=rtb-xxxxxxxx
```

Now add routes.

Private route table → public VPC:

```bash id="p5zhup"
aws ec2 create-route \
  --route-table-id $PRIV_RT \
  --destination-cidr-block 10.20.0.0/16 \
  --vpc-peering-connection-id $PEER
```

Public route table → private VPC:

```bash id="fsv7w5"
aws ec2 create-route \
  --route-table-id $PUB_RT \
  --destination-cidr-block 10.10.0.0/16 \
  --vpc-peering-connection-id $PEER
```

Then get the public instance IP:

```bash id="3pkjlwm"
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-pub-ec2" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
```

Copy that IP — next step is SSH + cron setup.
