#!/bin/bash
# Setup file for initializing the shell environment

read -p "port: " port
read -p "username: " username
read -s -p "password: " password

data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar https://info3103.cs.unb.ca:$port/signin)
echo $data
userId=$(echo $data | grep -Po "id\":\s*\K[0-9]+")
