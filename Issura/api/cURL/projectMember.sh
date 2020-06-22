#!/bin/bash
header="[Project Member]"

# ---------------[TEST SETUP]----------------------------------------------------------------------------------
echo -e "\n${header}Creating Test Project\n"
data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -b cookie-jar -d '{"name": "Super Awesome Project","description": "project desc goes here", "status": "OPN", "ownerId": "'"$userId"'"}' https://info3103.cs.unb.ca:$port/projects)
echo $data
projectId=$(echo $data | grep -Po "projects/\K[0-9]+")

# ---------------[MAIN TESTS]----------------------------------------------------------------------------------
echo -e "\n${header}Current Members\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers

echo -e "\n${header}Creating Member\n"
data=$(curl --insecure -i -s -X POST -b cookie-jar -H "Content-Type: application/json" -d '{"projectId":"'"$projectId"'", "userId": "'"$userId"'"}' https://info3103.cs.unb.ca:$port/projectMembers)
echo $data
memberId=$(echo $data | grep -Po "projectMembers/\K[0-9]+")

echo -e "\n${header}Getting Project Member ${memberId}\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers/${memberId}

echo -e "\n${header}Deleting Member ${memberId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers/${memberId}

echo -e "\n${header}Current Members\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers

# ---------------[TEST CLEANUP]----------------------------------------------------------------------------------
echo -e "\n${header}Deleting Test Project ${projectId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projects/${projectId}
