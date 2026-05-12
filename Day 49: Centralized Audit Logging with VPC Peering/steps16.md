Now you are correctly back on the public EC2 (`ip-10-20-1-118`).

Run:

```bash id="zjlwm2"
sudo /usr/local/bin/upload-to-s3.sh
```

If successful, it should upload `boots.log` to S3.

Then return to the `aws-client` terminal and verify:

```bash id="d9jlwm"
aws s3 ls s3://datacenter-s3-logs-20934/datacenter-priv-vpc/boot/
```

Expected output:

```text id="y0y2i4"
boots.log
```
