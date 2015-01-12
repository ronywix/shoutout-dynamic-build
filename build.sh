PROJECT="com.wix.shoutout.titanium.app-beta"
if [ $PROJECT == com.wix.shoutout.titanium.app-alpha ]; then
    echo "dev version - continue..."
elif [ $PROJECT == com.wix.shoutout.titanium.app-beta ]; then
    echo "This will upload code to beta repository. please enter beta code:"
    read CODE
    if [ "$CODE" != "beta_upload" ]; then
        echo "ERROR... wrong password beta upload"
        exit 1
    fi
else
    echo "This will upload code to production repository. please enter production code:"
    read CODE
    if [ "$CODE" != "prod_upload" ]; then
        echo "ERROR... wrong password production upload"
        exit 1
    fi
fi

echo "START BUILD.SH"
TIMESTAMP=$(date +%s)
VERSION="1.0"
VERSION="${VERSION}.${TIMESTAMP}";

cd ./utils/tipack-1.0.0/

_CLASSPATH=""

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    _CLASSPATH=$(echo *.jar | tr ' ' ':')

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under Linux platform
    echo "No classpath defined for linux!"

elif [ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]; then
    # Do something under Windows NT platform
    _CLASSPATH="*;./*"
fi

\rm -rf /tmp/shoutout
mkdir /tmp/shoutout

java  -Xmx1024m -cp $_CLASSPATH com.openrest.tipack.v1_0.Archiver -a ../../src /tmp/shoutout/archive.json
gzip /tmp/shoutout/archive.json

echo "Creating project"
curl -X "POST" -H "Content-Type: application/json" -d "{\"type\":\"package.create\", \"accessToken\":\"xyDSgsglBftgYjtUHgB0\", \"projectId\":\"${PROJECT}\", \"packageId\":\"${VERSION}\"}" https://packages.openrest.com/v1.0
UPLOAD_URL=`curl -X "POST" -H "Content-Type: application/json" -d "{\"type\":\"package.uploadurl\", \"accessToken\":\"xyDSgsglBftgYjtUHgB0\", \"projectId\":\"${PROJECT}\", \"packageId\":\"${VERSION}\"}" https://packages.openrest.com/v1.0 | jq -r '.value.url'`
echo "Getting Upload URL"
echo "          ...${UPLOAD_URL}"

echo "Uploading..."
FILES=`cd /tmp/shoutout ; find . -name "*.gz" | perl -ne '{chomp; s/^\.\///; print "-F $_=\@/tmp/shoutout/$_;type=application/json ";} ' ; cd ..`
CMD="curl ${FILES} ${UPLOAD_URL}"
echo ${CMD}
${CMD}

