The timeout happens because the private EC2 has no public access, so you cannot SSH to it directly from `aws-client`.

You must SSH through the public EC2 (jump host).

From `aws-client`, run:

```bash id="8r10jd"
ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
```

Then from inside the public EC2, SSH into the private EC2:

```bash id="9z6cly"
ssh -i /home/ubuntu/.ssh/datacenter-key.pem ubuntu@10.10.1.161
```

But first you need the key on the public instance.

While connected to the public EC2, run:

```bash id="0o3nfr"
mkdir -p ~/.ssh
```

Open another terminal on `aws-client` OR exit temporarily and copy the key:

```bash id="8n5r8r"
scp -i /root/.ssh/datacenter-key.pem /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175:/home/ubuntu/.ssh/
```

Now SSH again into the public instance:

```bash id="xuyb8m"
ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
```

Fix permissions:

```bash id="mqxsl0"
chmod 400 ~/.ssh/datacenter-key.pem
```

Now SSH into private EC2:

```bash id="bg5w2z"
ssh -i ~/.ssh/datacenter-key.pem ubuntu@10.10.1.161
```

Then configure:

```bash id="wjlwm4"
cat > /home/ubuntu/send-log.sh <<'EOF'
#!/bin/bash
scp -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/tmp/boots.log
EOF
```

Make executable:

```bash id="9c0udj"
chmod +x /home/ubuntu/send-log.sh
```

Test:

```bash id="1g3hny"
bash /home/ubuntu/send-log.sh
```

Add cron:

```bash id="1vxxe4"
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/send-log.sh") | crontab -
```

Then verify from `aws-client`:

```bash id="9f5v9k"
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```
