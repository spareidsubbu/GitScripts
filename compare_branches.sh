!#/bin/bash

###################################################################
# The script should be run as ./compare_branches.sh branch1 branch2
# where 
#       branch1 is the branch to be compared
#       branch2 is the branch to be compared with
###################################################################



# Delete temporary files
rm diff.txt
rm diff1.txt
rm diff.html

# Print branches that are input
echo $1 "Branch is being compared to "$2

# Pull from remote origin to refresh local repos
## Load the Git Creds
git -C /oms/repo/OMS config credential.helper store
## Switch to branch and pull the code from origin
git -C /oms/repo/OMS checkout $1
git -C /oms/repo/OMS pull origin $1
## Switch to branch and pull the code from origin
git -C /oms/repo/OMS checkout $2
git -C /oms/repo/OMS pull origin $2


# git compare branches
git -C /oms/repo/OMS diff $1 $2 >> diff.txt

sed -i "s/a\//Branch: $1 File:\//g" diff.txt
sed -i "s/b\//Branch: $2 File:\//g" diff.txt
sed -i "s/\r//g" diff.txt

while IFS= read -r line
do
	if [[ ${line:0:3} = "---" ]]
	then
		fileName=.${line:23:1000}
		git -C /oms/repo/OMS checkout --quiet $1
		lastCommitDate=$(git -C /oms/repo/OMS log -1 --pretty=format:'%ci' $filename)
		lastCommitAuthor=$(git -C /oms/repo/OMS log -1 --pretty=format:'%an' $filename)
		lastCommitMessage=$(git -C /oms/repo/OMS log -1 --pretty=format:'%B' $filename)
		echo "$line (Author: $lastCommitAuthor || Date: $lastCommitDate || Message: $lastCommitMessage)"
	elif [[ ${line:0:3} = "+++" ]]
	then
                fileName=.${line:23:1000}
		git -C /oms/repo/OMS checkout --quiet $2
                lastCommitDate=$(git -C /oms/repo/OMS log -1 --pretty=format:'%ci' $filename)
                lastCommitAuthor=$(git -C /oms/repo/OMS log -1 --pretty=format:'%an' $filename)
                lastCommitMessage=$(git -C /oms/repo/OMS log -1 --pretty=format:'%B' $filename)
                echo "$line (Author: $lastCommitAuthor || Date: $lastCommitDate || Message: $lastCommitMessage)"
	elif [[ ${line:0:5} = "index" ]]
	then
		fileName=.${line:23:1000}
	else
		echo "$line"
	fi
done < diff.txt >> diff1.txt


cat diff1.txt | ./diff2html.sh >> diff.html
