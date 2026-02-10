
# %>aws --version
# aws-cli/2.27.0 Python/3.13.11 Linux/6.18.4-100.fc42.x86_64 source/x86_64.fedora.42
#
#
AWS_CLI_VERSION=$(aws --version)
NS=default
OBC_NAME=test-bucket
OBC_UID=$(oc get obc $OBC_NAME -n $NS -o jsonpath={.metadata.uid})
BUCKET_NAME=$(oc get obc $OBC_NAME -n $NS -o jsonpath={.spec.bucketName})
OBC_SECRET=$(oc get secret -n "$NS" -o json \
  | jq -r --arg uid "$OBC_UID" '
  .items[]
  | select(any(.metadata.ownerReferences[]?; .uid == $uid))
  | .metadata.name
  ')

AWS_ACCESS_KEY_ID=$(oc get secret $OBC_SECRET -n $NS -o json | jq -r .data.AWS_ACCESS_KEY_ID | base64 -d)
AWS_SECRET_ACCESS_KEY=$(oc get secret $OBC_SECRET -n $NS -o json | jq -r .data.AWS_SECRET_ACCESS_KEY | base64 -d)
S3_ENDPOINT=$(oc get route s3 -n openshift-storage -o jsonpath={.spec.host})

echo "--- test parameters ---"

echo "AWS_CLI_VERSION=$AWS_CLI_VERSION"
echo "NS=$NS"
echo "OBC_NAME=$OBC_NAME"
echo "OBC_UID=$OBC_UID"
echo "OBC_SECRET=$OBC_SECRET"
echo "BUCKET_NAME=$BUCKET_NAME"
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
echo "S3_ENDPOINT=$S3_ENDPOINT"
echo

export PYTHONWARNINGS="ignore"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required 
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required

# fns and setup
rm -f demo.txt
rm -f demo-2.txt

check_last() {   
  local rc=$?  
  if [[ $rc -eq 0 ]]; then
    echo "OK"   
  else     
    echo "ERROR"
  fi 
}

echo "--- test0: ls ---"
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 ls s3://$BUCKET_NAME
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 ls s3://$BUCKET_NAME
check_last
echo && read -n 1 -s -t 5 key 

### test-1
echo "--- test1: upload with s3 cp ---"
echo 'echo "Hola Mundo" > demo.txt'
echo "Hola Mundo" > demo.txt
echo cat demo.txt
cat demo.txt
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp demo.txt s3://$BUCKET_NAME/
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp demo.txt s3://$BUCKET_NAME/
check_last
echo && read -n 1 -s -t 5 key 

### test-2
echo "--- test2: ls ---"
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 ls s3://$BUCKET_NAME
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 ls s3://$BUCKET_NAME
echo && read -n 1 -s -t 5 key 

### test-3
echo "--- test3: download with s3 cp ---"
rm -rf demo-2.txt
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp s3://$BUCKET_NAME/demo.txt demo-2.txt
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp s3://$BUCKET_NAME/demo.txt demo-2.txt
check_last
echo cat demo-2.txt
cat demo-2.txt
echo && read -n 1 -s -t 5 key 

### test-4
echo "--- test4: remote s3 cp  ---"
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp s3://$BUCKET_NAME/demo.txt s3://$BUCKET_NAME/demo-3.txt
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 cp s3://$BUCKET_NAME/demo.txt s3://$BUCKET_NAME/demo-3.txt
check_last
echo && read -n 1 -s -t 5 key 

### test-5
echo "--- test5: remove with s3 rm  ---"
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 rm s3://$BUCKET_NAME/demo.txt
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 rm s3://$BUCKET_NAME/demo.txt
check_last
echo aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 rm s3://$BUCKET_NAME/demo-3.txt
aws --no-verify-ssl --endpoint-url https://$S3_ENDPOINT s3 rm s3://$BUCKET_NAME/demo-3.txt
check_last
echo && read -n 1 -s -t 5 key 

# cleanup
rm -f demo.txt
rm -f demo-2.txt

