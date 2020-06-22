#!/bin/bash
header="[Issue Queries]"

# ---------------[TEST SETUP]----------------------------------------------------------------------------------
testIssues=()
testIssueTitles=("abc" "cde" "efg" "zzz")
testIssueDescriptions=("cba" "dec" "gfe" "ceh")
issueCount=${#testIssueTitles[@]}

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

echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

for ((i = 0; i < $issueCount; i++)); do
  echo -e "\n${header}Creating Issue\n"
  data=$(curl --insecure -s -i -H "Content-Type: application/json" -X POST -b cookie-jar -d '{"title":"'"${testIssueTitles[$i]}"'", "description":"'"${testIssueDescriptions[$i]}"'", "statusId":"'"$statusId"'", "creatorId":"'"$userId"'", "assigneeId":"'"$userId"'", "type":"BUG"}' https://info3103.cs.unb.ca:$port/projects/$projectId/issues)
  echo $data
  newIssueId=$(echo $data | grep -Po "issues/\K[0-9]+")
  testIssues+=("$newIssueId")
done
# ---------------[MAIN TESTS]----------------------------------------------------------------------------------

echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

echo -e "\n${header}Query Issue Titles for \"c\"\n"
curl --insecure -i -X GET -b cookie-jar "https://info3103.cs.unb.ca:$port/projects/$projectId/issues?title=c"

echo -e "\n${header}Query Issue Descriptions for \"c\"\n"
curl --insecure -i -X GET -b cookie-jar "https://info3103.cs.unb.ca:$port/projects/$projectId/issues?description=c"

echo -e "\n${header}Query Issues Title and Descriptions for \"e\"\n"
curl --insecure -i -X GET -b cookie-jar "https://info3103.cs.unb.ca:$port/projects/$projectId/issues?description=e&title=e"

echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

# ---------------[TEST CLEANUP]----------------------------------------------------------------------------------
for ((i = 0; i < $issueCount; i++)); do
  echo -e "\n${header}Deleting Issue $i\n"
  curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues/${testIssues[$i]}
done
echo -e "\n${header}Current Issues\n"
curl --insecure -i -X GET -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId/issues

echo -e "\n${header}Deleting Test Member ${memberId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projectMembers/${memberId}

echo -e "\n${header}Deleting Test Issue Status ${statusId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/issueStatuses/$statusId

echo -e "\n${header}Deleting Test Project ${projectId}\n"
curl --insecure -i -X DELETE -b cookie-jar https://info3103.cs.unb.ca:$port/projects/$projectId
