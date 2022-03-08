#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "[+] Action start"
SOURCE_BEFORE_DIRECTORY="${1}"
SOURCE_DIRECTORY="${2}"
DESTINATION_GITHUB_USERNAME="${3}"
DESTINATION_REPOSITORY_NAME="${4}"
GITHUB_SERVER="${5}"
USER_EMAIL="${6}"
USER_NAME="${7}"
DESTINATION_REPOSITORY_USERNAME="${8}"
TARGET_BRANCH="${9}"
COMMIT_MESSAGE="${10}"
TARGET_DIRECTORY="${11}"
SNIPS_TOOL_FILE_URL="${12}"
TARGET_GITHUB_USERNAME_API_SPECS="${13}"
TARGET_REPOSITORY_NAME_API_SPECS="${14}"
TARGET_BRANCH_API_SPECS="${15}"
TARGET_GITHUB_USERNAME_JAVA_SDK="${16}"
TARGET_REPOSITORY_NAME_JAVA_SDK="${17}"
TARGET_BRANCH_JAVA_SDK="${18}"


if [ -z "$DESTINATION_REPOSITORY_USERNAME" ]
then
	DESTINATION_REPOSITORY_USERNAME="$DESTINATION_GITHUB_USERNAME"
fi

if [ -z "$USER_NAME" ]
then
	USER_NAME="$DESTINATION_GITHUB_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

TEMP_DIR=$(mktemp -d)

echo "[+] Cloning destination git repository $DESTINATION_REPOSITORY_NAME"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"



#clone api-specs 
#echo "clone api-specs" 
git clone --single-branch --branch "$TARGET_BRANCH_API_SPECS" "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$TARGET_GITHUB_USERNAME_API_SPECS/$TARGET_REPOSITORY_NAME_API_SPECS.git" "$CLONE_DIR"/qingcloud-api-specs
ls -la "$CLONE_DIR"

#clone  java sdk (DESTINATION)
echo "clone  java sdk"
git clone --single-branch --branch "$TARGET_BRANCH_JAVA_SDK" "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" "$CLONE_DIR"/qingcloud-sdk-java
ls -la $CLONE_DIR/qingcloud-sdk-java/.git/
mkdir "$TEMP_DIR/qingcloud-sdk-java-temp"
mv "$CLONE_DIR/qingcloud-sdk-java/.git" "$TEMP_DIR/qingcloud-sdk-java-temp/.git"


ls -la "$CLONE_DIR"

#download  snips
#echo "download snips"
#cd $CLONE_DIR
#wget $SNIPS_TOOL_FILE_URL
#tar -xvf snips-v0.3.6-linux_amd64.tar.gz
#chmod -R 777 ./snips
#ls -la "$CLONE_DIR"
#cp snips /usr/local/bin/snips

# install snips
#echo "install snips"
#cd $CLONE_DIR
#git clone git@github.com:yunify/snips.git
#glide install
#make install


# snips api-specs to java sdk
echo " snips api-specs to java sdk"
snips -f $CLONE_DIR/qingcloud-api-specs/2013-08-30/swagger/api_v2.0.json -t $CLONE_DIR/qingcloud-sdk-java/tmpl -o $CLONE_DIR/qingcloud-sdk-java/src/main/java/com/qingcloud/sdk/service/


# push  java sdk
echo "push  java sdk"

ls -la "$CLONE_DIR"
 

# $TARGET_DIRECTORY is '' by default
ABSOLUTE_TARGET_DIRECTORY="$CLONE_DIR/qingcloud-sdk-java/$TARGET_DIRECTORY/"

echo "[+] Deleting $ABSOLUTE_TARGET_DIRECTORY"
rm -rf "$ABSOLUTE_TARGET_DIRECTORY"

echo "[+] Creating (now empty) $ABSOLUTE_TARGET_DIRECTORY"
mkdir -p "$ABSOLUTE_TARGET_DIRECTORY"

echo "[+] Listing Current Directory Location"
ls -al

echo "[+] Listing root Location"
ls -al /


mv "$TEMP_DIR/qingcloud-sdk-java-temp/.git" "$CLONE_DIR/qingcloud-sdk-java/.git"

echo "[+] List contents of $SOURCE_DIRECTORY"
ls "$SOURCE_DIRECTORY"

echo "[+] Checking if local $SOURCE_DIRECTORY exist"
if [ ! -d "$SOURCE_DIRECTORY" ]
then
	echo "ERROR: $SOURCE_DIRECTORY does not exist"
	echo "This directory needs to exist when push-to-another-repository is executed"
	echo
	echo "In the example it is created by ./build.sh: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L19"
	echo
	echo "If you want to copy a directory that exist in the source repository"
	echo "to the target repository: you need to clone the source repository"
	echo "in a previous step in the same build section. For example using"
	echo "actions/checkout@v2. See: https://github.com/cpina/push-to-another-repository-example/blob/main/.github/workflows/ci.yml#L16"
	exit 1
fi

echo "[+] Copying contents of source repository folder $SOURCE_DIRECTORY to folder $TARGET_DIRECTORY in git repo $DESTINATION_REPOSITORY_NAME"
cp -ra "$SOURCE_DIRECTORY"/. "$CLONE_DIR/qingcloud-sdk-java/$TARGET_DIRECTORY"
cd "$CLONE_DIR"/qingcloud-sdk-java

echo "add something different"
date +%s > report.txt

echo "[+] Files that will be pushed"
ls -la

echo "cat git config"
cat .git/config

#git config --system --unset credential.helper

ORIGIN_COMMIT="https://$GITHUB_SERVER/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
#COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
#COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

COMMIT_MESSAGE="See ORIGIN_COMMIT from $GITHUB_REF"


echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
#git push "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"

#git config remote.origin.url 'https://$USER_NAME:$API_TOKEN_GITHUB@github.com/${{ github.repository }}'

git remote set-url origin "https://conggeqc:$API_TOKEN_GITHUB@github.com/conggeqc/$TARGET_REPOSITORY_NAME_JAVA_SDK.git"
git config remote.origin.url "https://conggeqc:$API_TOKEN_GITHUB@github.com/conggeqc/$TARGET_REPOSITORY_NAME_JAVA_SDK.git"


#git push "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_JAVA_SDK"
git push "https://conggeqc:$API_TOKEN_GITHUB@$GITHUB_SERVER/$TARGET_GITHUB_USERNAME_JAVA_SDK/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_JAVA_SDK"
  

