#! /bin/bash

# install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
DEBIAN_FRONTEND=noninteractive sudo apt-get update 
DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install mongodb-org 

sudo systemctl enable mongod
sudo systemctl start mongod

sleep 10

# seed some initial records
cat <<EOF >> /tmp/m.js
use bbthe90s
db.products.update(
  { 'inv_id': 1}, 
  {'inv_id': 1, 'name':'Vase', 'cost':35.57, 'img':null}, 
  { upsert: true } 
)
db.products.update(
  { 'inv_id': 2}, 
  {'inv_id': 2, 'name':'Vegetable Peeler', 'cost':5.57, 'img':null}, 
  { upsert: true } 
)
db.products.update(
  { 'inv_id': 3}, 
  {'inv_id': 3, 'name':'Cordless Phone', 'cost':25.99, 'img':null}, 
  { upsert: true } 
)
db.products.update(
  { 'inv_id': 4}, 
  {'inv_id': 4, 'name':'Beanie Baby', 'cost':9.99, 'img':null}, 
  { upsert: true } 
)

db.listings.update(
  { 'listing_id': 1 }, 
  { 'listing_id': 1, 'name':'first listing', 'reserve':12.95, 'current_bid': 23.43, 'img':null },
  { upsert: true } 
)

db.listings.update(
  { 'listing_id': 2 }, 
  { 'listing_id': 2, 'name':'second listing', 'reserve':5.68, 'current_bid': 23.43, 'img':null },
  { upsert: true } 
)
db.listings.update(
  { 'listing_id': 3 }, 
  { 'listing_id': 3, 'name':'third listing', 'reserve':102.87, 'current_bid': 78.89, 'img':null },
  { upsert: true } 
)

db.listings.update(
  { 'listing_id': 4 }, 
  { 'listing_id': 4, 'name':'fourth listing', 'reserve':0, 'current_bid': 4.50, 'img':null },
  { upsert: true } 
)
EOF

mongo < /tmp/m.js