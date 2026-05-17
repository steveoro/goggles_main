# HOW-TO: Build Docker containers on localhost

## Prerequisites:
- Have `config/master.key` present
- Set DOCKER_TAG to the proper target version; for ex: "0.8.22" or "0.8.22.feature-branch" (e.g.: "0.9.00.rails-8.1")
- Get the other reserved values from the private docs.

```bash
export DOCKER_TAG="0.9.00.rails-8.1"

export RAILS_MASTER_KEY="$(cat config/master.key)"
```


Run the following, 1 statement at a time:

```bash
echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin

docker pull $DOCKERHUB_USERNAME/goggles-main:latest
export DOCKER_BUILDKIT=1

docker build \
  --secret id=rails_master_key,env=RAILS_MASTER_KEY \
  -t $DOCKERHUB_USERNAME/goggles-main:$DOCKER_TAG \
  --cache-from=$DOCKERHUB_USERNAME/goggles-main:latest \
  -f Dockerfile.prod .

docker push $DOCKERHUB_USERNAME/goggles-main:$DOCKER_TAG
```

## Staging example:

```bash
docker build --network=host --progress=plain --secret id=rails_master_key,src="<full_path_to>/master.key" -t $DOCKERHUB_USERNAME/goggles-main:latest -f Dockerfile.staging .
```

## Production example:

```bash
docker build --network=host --progress=plain --secret id=rails_master_key,src="<full_path_to>/master.key" -t $DOCKERHUB_USERNAME/goggles-main:$DOCKER_TAG -f Dockerfile.prod .
```
