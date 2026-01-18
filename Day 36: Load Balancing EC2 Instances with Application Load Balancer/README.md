# AWS Infrastructure - Nautilus DevOps Project

## Overview
This Terraform configuration creates a complete AWS infrastructure setup including:

1. **EC2 Instance with Web Server** - Ubuntu-based instance running Nginx
2. **Application Load Balancer (ALB)** - For high availability and traffic management
3. **Target Group** - Routes traffic from ALB to EC2 instance
4. **Security Groups** - Network security configuration
5. **Kinesis Data Stream** - For real-time data processing
6. **SNS Topic** - For notifications

## Architecture

```
Internet → ALB (devops-alb) → Target Group (devops-tg) → EC2 (devops-ec2) [Nginx]
           Port 80              Port 80                   Port 80
```

## Prerequisites

### 1. AWS Credentials
You have been provided with temporary AWS credentials:

- **Console URL**: https://341635973749.signin.aws.amazon.com/console?region=us-east-1
- **Username**: kk_labs_user_710522
- **Password**: w^D%@J8^eMVH
- **Valid Period**: Sun Jan 18 13:36:05 UTC 2026 to Sun Jan 18 14:36:05 UTC 2026
- **Region**: us-east-1

### 2. Configure AWS CLI

On the `aws-client` host, run:

```bash
# Display credentials
showcreds

# Configure AWS CLI
aws configure
```

Enter the following when prompted:
- **AWS Access Key ID**: [From showcreds output]
- **AWS Secret Access Key**: [From showcreds output]
- **Default region**: us-east-1
- **Default output format**: json

### 3. Required Tools
- Terraform (version 1.0 or higher)
- AWS CLI configured with proper credentials

## Project Structure

```
/home/bob/terraform/
├── main.tf          # Main Terraform configuration
└── README.md        # This documentation
```

## Resources Created

### 1. Security Group (devops-sg)
- **Purpose**: Attached to EC2 instance
- **Inbound Rules**: 
  - Port 80 (HTTP) from default security group (ALB)
- **Outbound Rules**: All traffic allowed

### 2. Default Security Group (Modified)
- **Purpose**: Attached to ALB
- **Added Rule**: Port 80 (HTTP) from Internet (0.0.0.0/0)
![image]()
### 3. EC2 Instance (devops-ec2)
- **Name**: devops-ec2
- **AMI**: Latest Ubuntu 22.04 LTS
- **Instance Type**: t2.micro
- **Security Group**: devops-sg
- **User Data**: Installs and starts Nginx
- **Web Server**: Nginx serving on port 80

### 4. Application Load Balancer (devops-alb)
- **Name**: devops-alb
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Security Group**: Default security group
- **Subnets**: All subnets in default VPC
- **Listener**: Port 80 (HTTP)
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/b0ce22f0300e9858b5305aea00dcbd5b768a6a17/Day%2036%3A%20Load%20Balancing%20EC2%20Instances%20with%20Application%20Load%20Balancer/Screenshot%202026-01-18%20194518.png)
### 5. Target Group (devops-tg)
- **Name**: devops-tg
- **Port**: 80
- **Protocol**: HTTP
- **Health Check**: 
  - Path: /
  - Interval: 30 seconds
  - Healthy threshold: 2
  - Unhealthy threshold: 2

### 6. Kinesis Data Stream (nautilus-stream)
- **Shard Count**: 1
- **Retention**: 24 hours
![image]()
### 7. SNS Topic (nautilus-notifications)
- **Name**: nautilus-notifications

## Deployment Steps
![image](https://github.com/abhijitray7810/100-Days-of-Cloud-AWS-Kodekloud/blob/1e2136f09150cb5c3eb93a804500cec2f2144c58/Day%2036%3A%20Load%20Balancing%20EC2%20Instances%20with%20Application%20Load%20Balancer/Screenshot%202026-01-18%20194504.png)
### Step 1: Navigate to Terraform Directory

```bash
cd /home/bob/terraform
```

Or in VS Code:
- Right-click under EXPLORER section
- Select "Open in Integrated Terminal"

### Step 2: Initialize Terraform

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
...
Terraform has been successfully initialized!
```

### Step 3: Validate Configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 4: Review Execution Plan

```bash
terraform plan
```

This will show:
- Resources to be created (EC2, ALB, Target Group, Security Groups, etc.)
- No resources to modify or destroy

### Step 5: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

Expected output:
```
...
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "devops-alb-xxxxxxxxxx.us-east-1.elb.amazonaws.com"
alb_url = "http://devops-alb-xxxxxxxxxx.us-east-1.elb.amazonaws.com"
ec2_instance_id = "i-xxxxxxxxxxxxxxxxx"
ec2_public_ip = "xx.xx.xx.xx"
...
```

### Step 6: Wait for Resources to Initialize

**IMPORTANT**: After `terraform apply` completes:

1. **Wait 2-3 minutes** for:
   - EC2 instance to fully boot
   - User data script to install Nginx
   - ALB health checks to pass
   - Target to become healthy

2. **Check Target Health**:
   ```bash
   aws elbv2 describe-target-health \
     --target-group-arn $(terraform output -raw target_group_arn)
   ```

   Wait until you see:
   ```json
   {
     "State": "healthy"
   }
   ```

## Verification

### Method 1: Access via ALB DNS (Recommended)

```bash
# Get the ALB URL
terraform output alb_url

# Test with curl
curl $(terraform output -raw alb_url)
```

Expected output:
```html
<h1>Hello from DevOps EC2 Instance</h1>
```

### Method 2: Access via Browser

1. Get the ALB DNS name:
   ```bash
   terraform output alb_dns_name
   ```

2. Open in browser:
   ```
   http://devops-alb-xxxxxxxxxx.us-east-1.elb.amazonaws.com
   ```

3. You should see: **"Hello from DevOps EC2 Instance"**

### Method 3: Verify in AWS Console

1. **EC2 Dashboard**:
   - Navigate to EC2 → Instances
   - Find `devops-ec2` instance (should be running)

2. **Load Balancer Dashboard**:
   - Navigate to EC2 → Load Balancers
   - Find `devops-alb` (should be active)

3. **Target Groups**:
   - Navigate to EC2 → Target Groups
   - Find `devops-tg`
   - Check "Targets" tab
   - Instance should show as "healthy"

4. **Security Groups**:
   - Navigate to EC2 → Security Groups
   - Verify `devops-sg` exists
   - Check default security group has port 80 open

### Method 4: Check with AWS CLI

```bash
# Check EC2 instance status
aws ec2 describe-instances \
  --instance-ids $(terraform output -raw ec2_instance_id) \
  --query 'Reservations[0].Instances[0].State.Name'

# Check ALB status
aws elbv2 describe-load-balancers \
  --names devops-alb \
  --query 'LoadBalancers[0].State.Code'

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

### Verify "No Changes" State

```bash
terraform plan
```

Should return:
```
No changes. Your infrastructure matches the configuration.
```

## Troubleshooting

### Issue 1: ALB returns 502/503 Error

**Cause**: Target is unhealthy or Nginx not started

**Solution**:
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# SSH into instance and check Nginx (if you have SSH access)
sudo systemctl status nginx

# Wait longer - it can take 2-5 minutes for everything to initialize
```

### Issue 2: "Connection Timed Out"

**Cause**: Security group rules not applied correctly

**Solution**:
```bash
# Verify security group rules
aws ec2 describe-security-groups \
  --group-names devops-sg default

# Ensure default SG has port 80 open from 0.0.0.0/0
# Ensure devops-sg has port 80 open from default SG
```

### Issue 3: Target Shows as "Unhealthy"

**Cause**: Nginx not running or health check failing

**Solution**:
1. Wait 2-3 minutes for user data script to complete
2. Check health check configuration in target group
3. Verify Nginx is listening on port 80

### Issue 4: AMI Not Found

**Cause**: Ubuntu AMI not available in region

**Solution**:
The configuration uses a data source to automatically find the latest Ubuntu AMI. If this fails, check:
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images[0].ImageId'
```

### Issue 5: Credentials Expired

**Cause**: Working beyond the 1-hour window

**Solution**:
- Re-run `showcreds` on aws-client host
- Update AWS CLI credentials
- Re-run terraform commands

## Testing the Setup

### Test 1: Basic HTTP Request

```bash
curl -v $(terraform output -raw alb_url)
```

### Test 2: Load Test (Optional)

```bash
# Install apache2-utils if not present
sudo apt-get install apache2-utils

# Run 100 requests
ab -n 100 -c 10 $(terraform output -raw alb_url)/
```

### Test 3: Multiple Requests

```bash
for i in {1..10}; do
  curl $(terraform output -raw alb_url)
  sleep 1
done
```

## Architecture Details

### Traffic Flow

1. User makes HTTP request to ALB DNS name
2. ALB (port 80) receives the request
3. ALB forwards to Target Group
4. Target Group routes to healthy target (EC2 instance)
5. EC2 instance (port 80) Nginx processes request
6. Response flows back through ALB to user

### Security Flow

1. Internet → Default SG (port 80 allowed)
2. ALB → devops-sg (port 80 from default SG allowed)
3. EC2 instance receives traffic only from ALB

### Health Check Flow

1. ALB sends HTTP GET to / on port 80 every 30 seconds
2. If 2 consecutive checks succeed → Target is "healthy"
3. If 2 consecutive checks fail → Target is "unhealthy"
4. Only healthy targets receive traffic

## Best Practices Implemented

✅ **High Availability**: ALB distributes traffic across availability zones
✅ **Security**: EC2 only accepts traffic from ALB, not directly from Internet
✅ **Health Monitoring**: Automatic health checks ensure only healthy instances receive traffic
✅ **Automation**: User data script automatically configures web server
✅ **Infrastructure as Code**: All resources defined in Terraform
✅ **Tagging**: All resources properly tagged for identification

## Scaling Considerations

### To Add More EC2 Instances

```hcl
resource "aws_instance" "devops_ec2_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  user_data              = aws_instance.devops_ec2.user_data
  
  tags = {
    Name = "devops-ec2-2"
  }
}

resource "aws_lb_target_group_attachment" "devops_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.devops_tg.arn
  target_id        = aws_instance.devops_ec2_2.id
  port             = 80
}
```

### To Use Auto Scaling

Consider replacing standalone EC2 with Auto Scaling Group for automatic scaling based on load.

## Cost Estimation

**Hourly costs** (approximate):
- EC2 t2.micro: $0.0116/hour
- Application Load Balancer: $0.0225/hour
- Data transfer: Variable

**Total**: ~$0.034/hour or ~$25/month (excluding data transfer)

## Monitoring

### CloudWatch Metrics to Monitor

**ALB Metrics**:
- `TargetResponseTime`: Response time from targets
- `RequestCount`: Number of requests
- `HealthyHostCount`: Number of healthy targets
- `UnHealthyHostCount`: Number of unhealthy targets
- `HTTPCode_Target_2XX_Count`: Successful responses

**EC2 Metrics**:
- `CPUUtilization`: CPU usage percentage
- `NetworkIn/Out`: Network traffic
- `StatusCheckFailed`: Instance health

### View Metrics

```bash
# ALB request count (last hour)
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=app/devops-alb/xxxx \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# EC2 CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=$(terraform output -raw ec2_instance_id) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

## Cleanup

When you're done, destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

This will delete:
- EC2 instance
- Application Load Balancer
- Target Group
- Security Group (devops-sg)
- Security Group Rule in default SG
- Kinesis Stream
- SNS Topic

**Note**: The default security group itself won't be deleted (it's managed by AWS), but the rule we added will be removed.

## Additional Commands

### Get All Outputs

```bash
terraform output
```

### Get Specific Output

```bash
terraform output alb_url
terraform output -raw alb_dns_name
terraform output ec2_public_ip
```

### View Terraform State

```bash
terraform show
```

### List All Resources

```bash
terraform state list
```

## Integration with Other Services

### Send ALB Metrics to SNS

You can set up CloudWatch alarms to notify via SNS:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name devops-alb-unhealthy-targets \
  --alarm-description "Alert when targets are unhealthy" \
  --metric-name UnHealthyHostCount \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 2 \
  --alarm-actions $(terraform output -raw sns_topic_arn)
```

## Support & Resources

- **AWS Documentation**: 
  - [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
  - [ALB Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- **Terraform Documentation**: 
  - [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **Team**: Nautilus DevOps Team

---

**Created**: January 2025  
**Maintained By**: Nautilus DevOps Team  
**Region**: us-east-1  
**Terraform Version**: >= 1.0  
**AWS Provider**: ~> 5.0
