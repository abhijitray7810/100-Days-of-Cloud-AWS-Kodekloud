You are currently inside the public EC2, so `/root/.ssh/datacenter-key.pem` does not exist there.

Exit back to `aws-client` first:

```bash id="lvsl2q"
exit
```

Now from `aws-client`, copy the key to the public EC2:

```bash id="fjlwm1"
scp -i /root/.ssh/datacenter-key.pem /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175:/home/ubuntu/.ssh/
```

Now SSH again into the public EC2:

```bash id="b61f6g"
ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
```

Fix permissions:

```bash id="z2uwy0"
chmod 400 ~/.ssh/datacenter-key.pem
```

Now SSH into the private EC2:

```bash id="2u9b21"
ssh -i ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161
```

Once connected, configure the script:

```bash id="byjlwm"
cat > /home/ubuntu/send-log.sh <<'EOF'
#!/bin/bash
scp -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/tmp/boots.log
EOF
```

Make executable:

```bash id="xy9jj8"
chmod +x /home/ubuntu/send-log.sh
```

Test:

```bash id="ysn2gr"
bash /home/ubuntu/send-log.sh
```

Then add cron:

```bash id="y7zv8m"
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/send-log.sh") | crontab -
```

Finally verify from `aws-client`:

```bash id="kjlwm8"
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```
