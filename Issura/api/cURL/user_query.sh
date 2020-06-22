#!/bin/bash
header="[User Queries]"

# ---------------[TEST SETUP]----------------------------------------------------------------------------------
testUsers=()
testUserNames=("ksd45" "tsd4" "kai8" "bob87" "ash9")
testUserNicks=("kim_ftw_87" "taz" "kawaii_90210" "bob_the_builder" "pokemaster")
userCount=${#testUserNames[@]}

echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

for ((i = 0; i < $userCount; i++)); do
  echo -e "\n${header}Creating User #$i\n"
  data=$(curl --insecure -i -s -X POST -b cookie-jar -H "Content-Type: application/json" -d '{"username":"'"${testUserNames[$i]}"'", "nickname": "'"${testUserNicks[$i]}"'"}' https://info3103.cs.unb.ca:$port/users)
  echo $data
  newUserId=$(echo $data | grep -Po "users/\K[0-9]+")
  testUsers+=("$newUserId")
done

# ---------------[MAIN TESTS]----------------------------------------------------------------------------------
echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

echo -e "\n${header}Query Users for \"87\"\n"
curl --insecure -i -X GET -b cookie-jar 'https://info3103.cs.unb.ca:'$port'/users?search=87'

echo -e "\n${header}Query Users for \"ka\"\n"
curl --insecure -i -X GET -b cookie-jar 'https://info3103.cs.unb.ca:'$port'/users?search=ka'

echo -e "\n${header}Query Users for \"9\"\n"
curl --insecure -i -X GET -b cookie-jar 'https://info3103.cs.unb.ca:'$port'/users?search=9'

echo -e "\n${header}Current Users\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users

# ---------------[TEST CLEANUP]----------------------------------------------------------------------------------
for ((i = 0; i < $userCount; i++)); do
  echo -e "\n${header}Deleting User #$i (will 403)\n"
  curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/users/${testUsers[$i]}
done
