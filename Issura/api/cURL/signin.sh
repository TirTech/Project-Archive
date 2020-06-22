#!/bin/bash
header="[SignIn]"

echo -e "\n${header}Signing in\n"
curl --insecure -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar https://info3103.cs.unb.ca:$port/signin

echo -e "\n${header}Current Status:\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/signin

echo -e "\n${header}Signing out...\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/signin

echo -e "\n${header}Current Status:\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/signin
