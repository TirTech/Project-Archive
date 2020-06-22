#!/bin/bash
header="[Issue]"

# ---------------[TEST SETUP]----------------------------------------------------------------------------------
echo -e "\n${header}Creating Test Project\n"
data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -b cookie-jar -d '{"name": "Super Awesome Project","description": "project desc goes here", "status": "OPN", "ownerId": "'"$userId"'"}' https://info3103.cs.unb.ca:$port/projects)
echo $data
projectId=$(echo $data | grep -Po "projects/\K[0-9]+")

echo -e "\n${header}Creating Test Issue Status\n"
data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -b cookie-jar -d '{"name": "QA Ready","color": "AABBCC", "projectId": "'"$projectId"'", "typeCode": "BUG"}' https://info3103.cs.unb.ca:$port/issueStatuses)
echo $data
statusId=$(echo $data | grep -Po "issueStatuses/\K[0-9]+")

echo -e "\n${header}Creating Test Member\n"
data=$(curl --insecure -i -s -X POST -b cookie-jar -H "Content-Type: application/json" -d '{"projectId":"'"$projectId"'", "userId": "'"$userId"'"}' https://info3103.cs.unb.ca:$port/projectMembers)
echo $data
memberId=$(echo $data | grep -Po "projectMembers/\K[0-9]+")
# ---------------[MAIN TESTS]----------------------------------------------------------------------------------
echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

echo -e "\n${header}Creating Issue\n"
data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -b cookie-jar -d '{"title":"Fix Duplicate Requests", "description":"Filter duplicate API requests with an Idempotency Token on api v3", "statusId":"'"$statusId"'", "creatorId":"'"$userId"'", "assigneeId":"'"$userId"'", "type":"BUG"}' https://info3103.cs.unb.ca:$port/projects/$projectId/issues)
echo $data
issueId=$(echo $data | grep -Po "issues/\K[0-9]+")

echo -e "\n${header}Getting Issue ${issueId}\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues/$issueId

echo -e "\n${header}Updating Issue ${issueId}\n"
curl --insecure -i -H "Content-Type: application/json" -X PUT -b cookie-jar -d '{"title":"Fix Requests", "description":"v4 fix", "statusId":"'"$statusId"'", "assigneeId":"'"$userId"'", "type":"FTR"}' https://info3103.cs.unb.ca:$port/projects/$projectId/issues/$issueId

echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

echo -e "\n${header}Getting Issues From User URL\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/users/$userId/issues

echo -e "\n${header}Deleting Issue ${issueId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues/$issueId

echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

# ---------------[TEST CLEANUP]----------------------------------------------------------------------------------
echo -e "\n${header}Deleting Test Member ${memberId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers/${memberId}

echo -e "\n${header}Deleting Test Issue Status ${statusId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/issueStatuses/$statusId

echo -e "\n${header}Deleting Test Project ${projectId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId
