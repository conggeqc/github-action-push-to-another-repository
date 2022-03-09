#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "[+] Action start"
#SOURCE_BEFORE_DIRECTORY="${1}"
#SOURCE_DIRECTORY="${2}"
#DESTINATION_GITHUB_USERNAME="${3}"
#DESTINATION_REPOSITORY_NAME="${4}"
#GITHUB_SERVER="${5}"
#USER_EMAIL="${6}"
#USER_NAME="${7}"
#DESTINATION_REPOSITORY_USERNAME="${8}"
#TARGET_BRANCH="${9}"
#COMMIT_MESSAGE="${10}"
#TARGET_DIRECTORY="${11}"
#SNIPS_TOOL_FILE_URL="${12}"
#TARGET_GITHUB_USERNAME_API_SPECS="${13}"
#TARGET_REPOSITORY_NAME_API_SPECS="${14}"
#TARGET_BRANCH_API_SPECS="${15}"
#TARGET_GITHUB_USERNAME_JAVA_SDK="${16}"
#TARGET_REPOSITORY_NAME_JAVA_SDK="${17}"
#TARGET_BRANCH_JAVA_SDK="${18}"



USER_EMAIL="${1}"
USER_NAME="${2}"
COMMIT_MESSAGE="${3}"
#TARGET_BRANCH="${4}"

TARGET_GITHUB_USERNAME_API_SPECS="${4}"
TARGET_REPOSITORY_NAME_API_SPECS="${5}"
TARGET_BRANCH_API_SPECS="${6}"
TARGET_GITHUB_USERNAME_JAVA_SDK="${7}"
TARGET_REPOSITORY_NAME_JAVA_SDK="${8}"
TARGET_BRANCH_JAVA_SDK="${9}"




#if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
#then
#	DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
#fi
#
#if [ -z "$USER_NAME" ]
#then
#	USER_NAME="$DESTINATION_GITHUB_USERNAME"
#fi

CLONE_DIR=$(mktemp -d)

#TEMP_DIR=$(mktemp -d)

# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"


echo "[+] Cloning destination git repository apispecs java"
#clone api-specs 
#echo "clone api-specs" 
git clone --single-branch --branch "$TARGET_BRANCH_API_SPECS" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_API_SPECS/$TARGET_REPOSITORY_NAME_API_SPECS.git" "$CLONE_DIR"/qingcloud-api-specs
ls -la "$CLONE_DIR"

#clone  java sdk (DESTINATION)
echo "clone  java sdk"
git clone --single-branch --branch "$TARGET_BRANCH_JAVA_SDK" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" "$CLONE_DIR"/qingcloud-sdk-java
#ls -la $CLONE_DIR/qingcloud-sdk-java/.git/
#mkdir "$TEMP_DIR/qingcloud-sdk-java-temp"
#mv "$CLONE_DIR/qingcloud-sdk-java/.git" "$TEMP_DIR/qingcloud-sdk-java-temp/.git"

echo "current branch"
cd "$CLONE_DIR"/qingcloud-sdk-java && git branch


ls -la "$CLONE_DIR"


# snips api-specs to java sdk
echo " snips api-specs to java sdk"

ls -alth $CLONE_DIR/qingcloud-api-specs
ls -alth $CLONE_DIR/qingcloud-sdk-java

snips -f $CLONE_DIR/qingcloud-api-specs/2013-08-30/swagger/api_v2.0.json -t $CLONE_DIR/qingcloud-sdk-java/tmpl -o $CLONE_DIR/qingcloud-sdk-java/src/main/java/com/qingcloud/sdk/service/


# push  java sdk
echo "push  java sdk"

cd "$CLONE_DIR"/qingcloud-sdk-java

echo "add something different"
#date +%s > report.txt
date +%c > report.txt

echo "[+] Files that will be pushed"
ls -la

echo "cat git config"
cat .git/config


#  COMMIT_MESSAGE
#ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
#COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
#COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"




echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist

git remote set-url origin "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git"
git config remote.origin.url "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git"

#echo "cat git config"
#cat .git/config


#git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_JAVA_SDK"

echo 'git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_JAVA_SDK"'
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_JAVA_SDK"
  

