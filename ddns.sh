#!/bin/bash

IP_FILE="$BASEDIR/current_ip"
JSON_FILE="$BASEDIR/changes.json"
HOSTED_ZONE_ID="YOUR HOSTED ZONE ID"

CURRENT_IP=$(curl -s inet-ip.info)

if [ ! -f "$IP_FILE" ]; then
  echo "" > "$IP_FILE"
fi

OLD_IP=$(cat "$IP_FILE")

if [ "$CURRENT_IP" != "$OLD_IP" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') IP changed from $OLD_IP to $CURRENT_IP"
  echo "$CURRENT_IP" > "$IP_FILE"
  jq --arg ip "$CURRENT_IP" '.Changes[0].ResourceRecordSet.ResourceRecords[0].Value = $ip' "$JSON_FILE" > tmp && mv tmp "$JSON_FILE"
  aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://$JSON_FILE \
	  | jq -r '"Id: \(.ChangeInfo.Id)\nSubmittedAt: \(.ChangeInfo.SubmittedAt)"'
fi

