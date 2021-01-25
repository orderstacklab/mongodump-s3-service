#!/bin/bash

if [[ $KEEP_OLD_FILES_DAYS == "" ]]
then
	echo "skipping old file deletions"
else
	echo "deleting old files"
	find /usr/files -mtime +$KEEP_OLD_FILES_DAYS -exec rm -f {} \;
fi

if [[ $MONGO_HOST == "" ]]
then
	echo "Mongo db host not found"
	exit 1
fi

if [[ $MONGO_PORT == "" ]]
then
	echo "Trying default mongo port: 27017"
	MONGO_PORT=27017
fi

dateString="$(date +%d-%m-%Y-%H_%M_%S)"
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
	args+=("--username" $MONGO_USER "--password" $MONGO_PASSWORD "--authenticationDatabase=$AUTH_DB" ) 
else 
	echo "Skipping user authentication"
fi

awsArgs=($path$filename s3://$BUCKET_NAME/$BUCKET_PATH/$filename)

export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$DEFAULT_REGION

if [[ $ENDPOINT != "" ]]
then
	echo "Setting ENDPOINT for s3 api"
	awsArgs+=("--endpoint $ENDPOINT")
fi

echo "Running mongodump and s3 push"
# echo ${args[@]}
# echo ${awsArgs[@]}

if mongodump ${args[@]} && aws s3 cp ${awsArgs[@]} ; then
    echo "Backup succeeded"
	if [[ $HEALTHCHECK_IO_CHECK_URL != "" ]]
	then
		curl -m 10 --retry 5 $HEALTHCHECK_IO_CHECK_URL
	fi
else
    echo "Backup failed"
	if [[ $HEALTHCHECK_IO_CHECK_URL != "" ]]
	then
		curl --retry 3 $HEALTHCHECK_IO_CHECK_URL/fail
	fi
fi