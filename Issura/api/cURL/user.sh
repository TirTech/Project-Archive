#!/bin/bash
header="[User]"

# ---------------[TEST SETUP]----------------------------------------------------------------------------------
#nothing here

# ---------------[MAIN TESTS]----------------------------------------------------------------------------------
echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

echo -e "\n${header}Creating User\n"
data=$(curl --insecure -i -s -X POST -b cookie-jar -H "Content-Type: application/json" -d '{"username":"bfrankli", "nickname": "bf"}' https://info3103.cs.unb.ca:$port/users)
echo $data
newUserId=$(echo $data | grep -Po "users/\K[0-9]+")

echo -e "\n${header}Getting User ${userId}\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users/${newUserId}

echo -e "\n${header}Updating Logged In User ${userId}\n"
curl --insecure -i -H "Content-Type: application/json" -X PUT -b cookie-jar -d '{"nickname": "new nickname"}' https://info3103.cs.unb.ca:$port/users/${userId}

echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

echo -e "\n${header}Deleting User ${newUserId} (this will 403 as they are not the logged in user)\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/users/${newUserId}

echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

# ---------------[TEST CLEANUP]----------------------------------------------------------------------------------
#noting here
