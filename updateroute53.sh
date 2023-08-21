#!/bin/bash

# Variables - set these
hostname=www.example.com.
zoneid=Z074XXXXXXXXXXXXXXX
aws_access_key=AKIAXXXXXXXXXXXXXX
aws_secret_key=8H6gXXXXXXXXXXXXXXXXXXXX

# Get current public IP
newip=$(curl http://checkip.amazonaws.com/ip)

#sanity chack to make sure the IP is good from the checkip url
if expr "$ip" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
  for i in 1 2 3 4; do
    if [ $(echo "$ip" | cut -d. -f$i) -gt 255 ]; then
      echo "fail not a valid ($ip)"
      exit 1
    fi
  done
  echo "success this looks like your IP  ($ip)"
else
  echo "fail not a valid ip  ($ip)"
  exit 1
fi

# Get current Route 53 IP
oldip=$(dig +short "$hostname" @ns-447.awsdns-55.com)

# Compare IPs
if [ "$newip" == "$oldip" ]; then
  exit 0
fi

# Prepare Route 53 update
cat > route53.json << EOF
{ 
  "Comment": "Dynamic DNS Update",
  "Changes": [
    {
      "Action": "UPSERT",  
      "ResourceRecordSet": {
         "Name": "$hostname",
         "Type": "A",
         "TTL": 300,
         "ResourceRecords": [{"Value": "$newip"}]
       }
    }
  ]
} 
EOF

# Update Route 53
aws route53 change-resource-record-sets --hosted-zone-id "$zoneid" --change-batch file://route53.json
rm route53.json
