# /bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: ./build-docker.sh def_file_name version_number"
    exit 1
fi

if [[ -z "$2" ]]; then
    echo "Usage: ./build-docker.sh def_file_name version_number"
    exit 1
fi

echo "Starting build..."
cp $1 ./prosody.deb
docker build -t prosody/prosody:$2 .
docker push prosody/prosody

echo "Cleaning up..."
docker rmi prosody/prosody:$2
rm ./prosody.deb