Everything is almost complete.
The remaining issue is only file permissions on the public EC2.

You are currently inside the private EC2.

Change the destination path from `/tmp/boots.log` to the ubuntu home directory.

Update the script:

```bash id="2q9g4n"
cat > /home/ubuntu/send-log.sh <<'EOF'
#!/bin/bash
scp -i /home/ubuntu/.ssh/datacenter-key.pem -o StrictHostKeyChecking=no /var/log/boots.log ubuntu@10.20.1.118:/home/ubuntu/boots.log
EOF
```

Make executable again:

```bash id="p8kx4r"
chmod +x /home/ubuntu/send-log.sh
```

Test:

```bash id="bjlwm8"
bash /home/ubuntu/send-log.sh
```

If no error appears, now exit back to the public EC2:

```bash id="q3c5u0"
exit
```

You should now be on:

```text id="8jv1f7"
ubuntu@ip-10-20-1-118
```

Update the upload script there:

```bash id="9vjlwm"
sudo tee /usr/local/bin/upload-to-s3.sh > /dev/null <<'EOF'
#!/bin/bash
aws s3 cp /home/ubuntu/boots.log s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/boots.log
EOF
```

Make executable:

```bash id="g0xx7w"
sudo chmod +x /usr/local/bin/upload-to-s3.sh
```

Test manually:

```bash id="s1t3bz"
sudo /usr/local/bin/upload-to-s3.sh
```

Now from `aws-client`, verify the final upload:

```bash id="y5jlwm"
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```

Expected:

```text id="8kdxr2"
boots.log
```
