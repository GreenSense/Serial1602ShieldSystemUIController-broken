token="$GHTOKEN"
repo="GreenSense/Serial1602ShieldSystemUIController"

if [ ! $token ]; then
  echo "The GHTOKEN environment variable hasn't been set."
  exit 1
fi


VERSION=$(cat version.txt)
BUILD_NUMBER=$(cat buildnumber.txt)

FULL_VERSION=$VERSION.$BUILD_NUMBER

BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

if [ "$BRANCH" = "dev" ]
then
    FULL_VERSION="$FULL_VERSION-dev"
fi

PROJECT_NAME=${PWD##*/}
FULL_PROJECT_NAME="$PROJECT_NAME.$FULL_VERSION"
echo "Project name: $PROJECT_NAME"

upload_url=$(curl -s -H "Authorization: token $token"  \
     -d "{\"tag_name\": \"$BRANCH\", \"name\":\"$PROJECT_NAME.$FULL_VERSION\",\"body\":\"$BRANCH release\"}"  \
     "https://api.github.com/repos/$repo/releases" | jq -r '.upload_url')

upload_url="${upload_url%\{*}"

echo "uploading asset to release to url : $upload_url"

curl -s -H "Authorization: token $token"  \
        -H "Content-Type: application/zip" \
        --data-binary @releases/$FULL_PROJECT_NAME.zip  \
        "$upload_url?name=$FULL_PROJECT_NAME.zip&label=$FULL_PROJECT_NAME.zip"
