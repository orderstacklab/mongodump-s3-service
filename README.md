## mongodump-s3-service

#### For running container on any host

```
docker run --name mongodump-s3-service \
		   -v ~/backup_files:/usr/files \
		   --network "host" \
		   --env-file .env \
		   -d \
		   rohandhamapurkar/mongodump-s3-service:latest
```

#### For taking instant mongodump on any host

```
docker exec -it mongodump-s3-service instant
```

#### For building local image and running the container

```
docker build --tag mongodump-s3-service:latest .

docker run --name mongodump-s3-service \
		   -v ~/backup_files:/usr/files \
		   --network "host" \
		   --env-file .env \
		   -d \
		   mongodump-s3-service:latest
```

### <b>Note: Please refer .sample.env for environment variables that are needed to create .env file</b>
