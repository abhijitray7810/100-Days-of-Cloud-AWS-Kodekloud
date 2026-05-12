Perfect. Now configure the public EC2 instance first.

# SSH Into Public EC2

```bash id="7ck2by"
chmod 400 /root/.ssh/datacenter-key.pem
```

```bash id="n53yqo"
ssh -i /root/.ssh/datacenter-key.pem ubuntu@3.83.189.175
```

If asked:

```text id="e4vz3u"
yes
```

---

# Install AWS CLI

Inside the public instance:

```bash id="k3mkm0"
sudo apt update
sudo apt install awscli -y
```

Verify:

```bash id="1ntr8r"
aws --version
```

---

# Create Upload Script

```bash id="s9cm0z"
sudo tee /usr/local/bin/upload-to-s3.sh > /dev/null <<'EOF'
#!/bin/bash
aws s3 cp /tmp/boots.log s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
EOF
```

Make executable:

```bash id="5e0msf"
sudo chmod +x /usr/local/bin/upload-to-s3.sh
```

Test manually:

```bash id="3mjlwm"
sudo touch /tmp/boots.log
sudo /usr/local/bin/upload-to-s3.sh
```

If no error appears, configure cron:

```bash id="jq11rp"
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/upload-to-s3.sh") | crontab -
```

Check cron:

```bash id="9axp3q"
crontab -l
```

You should see:

```text id="jzrfdn"
*/5 * * * * /usr/local/bin/upload-to-s3.sh
```

Then exit the instance:

```bash id="67g5ra"
exit
```

After returning to `aws-client`, we’ll configure the private EC2 instance to transfer `/var/log/boots.log` to the public instance.
