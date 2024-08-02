#!/bin/bash

# 密钥及帐户
API_KEY="" # API密钥
EMAIL="hainanidc@gmail.com" # 帐户信息

# 域名信息
DOMAIN="0898.us.kg" # 主域名信息
RECORD_NAME="10086" # 修改为二级域名名称

# 获取测试得到的优选IP
NEW_IP_ADDRESS=$(awk -F',' 'NR==2 {print $1}' result.csv)

# 获取区域ID号
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${API_KEY}" -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ -z "$ZONE_ID" ]; then
  echo "Error: Unable to retrieve Zone ID for the domain."
  exit 1
fi

# Get Record ID for the specified A record
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=A&name=${RECORD_NAME}.${DOMAIN}" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${API_KEY}" -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ -z "$RECORD_ID" ]; then
  echo "Error: Unable to retrieve Record ID for the specified A record."
  exit 1
fi

# Update A record with new IP address
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
  -H "X-Auth-Email: ${EMAIL}" \
  -H "X-Auth-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'${RECORD_NAME}'","content":"'${NEW_IP_ADDRESS}'","ttl":1,"proxied":false}'

echo "A record updated successfully."
