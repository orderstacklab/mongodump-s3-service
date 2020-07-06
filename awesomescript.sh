#!/bin/bash

if [[ $KEEP_OLD_FILES_DAYS == "" ]]
then
	echo "Setting KEEP_OLD_FILES_DAYS to 1"
	KEEP_OLD_FILES_DAYS=1
fi
echo "deleting old files"
find /usr/files -mtime +$KEEP_OLD_FILES_DAYS -exec rm -f {} \;

if [[ $MONGO_HOST == "" ]]
then
	echo "Mongo db host not found"
	exit 1
fi

if [[ $MONGO_PORT == "" ]]
then
	echo "Setting default mongo port as 27017"
	MONGO_PORT=27017
fi

dateString="$(date -u +%d-%m-%Y-%H_%M_%S)"
path=/usr/files/
filename=$(echo mongodump_$dateString.zip)
echo "Creating" $path$filename

args=("--host" $MONGO_HOST "--port" $MONGO_PORT "--archive=$path$filename" "--gzip")

if [[ $AUTH_DB == "" ]]
then
	echo "Setting default authentication database as 'admin'"
	AUTH_DB=admin
fi

if [[ $MONGO_USER != "" && $MONGO_PASSWORD != "" ]]
then
	args+=("--username" $MONGO_USER "--password" $MONGO_PASSWORD "--authenticationDatase=$AUTH_DB" ) 
else 
	echo "Skipping user authentication"
fi

echo "Running mongodump"
echo ${args[@]}
mongodump ${args[@]}

awsArgs=($path$filename s3://$BUCKET_NAME/$BUCKET_PATH/$filename)

export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$DEFAULT_REGION

if [[ $ENDPOINT != "" ]]
then
	echo "Setting ENDPOINT for s3 api"
	awsArgs+=("--endpoint $ENDPOINT")
fi

echo ${awsArgs[@]}

aws s3 cp ${awsArgs[@]}

# docker run -v ~/Desktop/backup_files:/usr/files --env-file .env rohandhamapurkar/mongodump-s3-service:1.0
# docker build --tag mongodump-s3-service:1.0 .