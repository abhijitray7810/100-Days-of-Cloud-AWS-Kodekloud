If that command is hanging or you are unsure, first verify the `s3-policy.json` file exists and is valid.

Run:

```bash id="g4ojf8"
cat s3-policy.json
```

It should look like:

```json id="9v53n0"
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
```

Then run again:

```bash id="56jlwm"
aws iam put-role-policy \
  --role-name datacenter-s3-role \
  --policy-name datacenter-s3-put \
  --policy-document file://s3-policy.json
```

If successful, AWS CLI usually returns no output and simply goes back to the prompt.

Then continue with:

```bash id="r2mhqb"
aws iam create-instance-profile \
  --instance-profile-name datacenter-s3-profile
```

```bash id="3o4lg2"
aws iam add-role-to-instance-profile \
  --instance-profile-name datacenter-s3-profile \
  --role-name datacenter-s3-role
```

Wait about 15–20 seconds before attaching the profile to the EC2 instance.
