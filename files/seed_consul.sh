#! /bin/bash

echo "Seeding initial application config in Consul..."

# web_client config
consul kv put web_client_conf/PRODUCT_URI http://localhost:10001
consul kv put web_client_conf/LISTING_URI http://localhost:10002

# product config
consul kv put product_conf/DB_ADDR 127.0.0.1
consul kv put product_conf/DB_PORT 5001

# listing config
consul kv put listing_conf/DB_URL localhost
consul kv put listing_conf/DB_PORT 8001
consul kv put listing_conf/DB_NAME bbthe90s
consul kv put listing_conf/DB_COLLECTION listings

echo "Done."

echo "Creating intentions..."

consul intention create -replace listing mongodb
consul intention create -replace product mongodb
consul intention create -replace web_client listing
consul intention create -replace web_client product
consul intention create -replace -deny web_client mongodb

echo "Done."

# TODO: pulled out "Connect: true" because it wasn't working...
# Actually, the template isnt working as expected period
#echo "Creating prepared query template for service failover..."
#curl \
#    --request POST \
#    --data \
#'{
#  "Name": "Generic_Failover",
#  "Template": {
#    "Type": "name_prefix_match"
#  },
#  "Service": {
#    "Service": "${name.full}"
#  }
#}' http://127.0.0.1:8500/v1/query


echo "Creating prepared query template for service failover..."
curl \
    --request POST \
    --data \
'{
  "Name": "mongodb",
  "Service": {
    "Service": "mongodb",
    "Connect": true,
    "Failover": {
      "NearestN": 2
    }
  }
}' http://127.0.0.1:8500/v1/query

curl \
    --request POST \
    --data \
'{
  "Name": "listing",
  "Service": {
    "Service": "listing",
    "Connect": true,
    "Failover": {
      "NearestN": 2
    }
  }
}' http://127.0.0.1:8500/v1/query

curl \
    --request POST \
    --data \
'{
  "Name": "product",
  "Service": {
    "Service": "product",
    "Connect": true,
    "Failover": {
      "NearestN": 2
    }
  }
}' http://127.0.0.1:8500/v1/query

curl \
    --request POST \
    --data \
'{
  "Name": "web_client",
  "Service": {
    "Service": "web_client",
    "Connect": true,
    "Failover": {
      "NearestN": 2
    }
  }
}' http://127.0.0.1:8500/v1/query

echo "Query template for Connect enabled services created!"

echo "Finished"




