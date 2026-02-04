#!/bin/bash

repo=cxl_run_qemu
artifacts_upload_dir=artifacts
artifacts_download_dir=artifacts-${RANDOM}


#artifacts="item1.zip item2.tar.gz item3.qcow"

GHCR_USER="MarekBykowski"
GHCR_TOKEN="g\
hp_FU32\
vNbprc3\
KsnZKm\
Nmbloh\
oXBE4x\
D0Sb6ng"

# Login to GHCR
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin

# Repository name must be lowercase
GHCR_USER=${GHCR_USER,,}

if [[ $1 == publish ]]; then
	pushd $artifacts_upload_dir
	artifacts_to_push=(*)
	for artifact in ${artifacts_to_push[@]}; do
		test -f $artifact || echo "$artifact doesn't exist!"
		ls $artifact

		filename=$(basename "$artifact")

		echo "Pushing $filename as $filename:v1"

		# Build Docker image
		docker build -t ghcr.io/$GHCR_USER/$filename:v1 \
		--build-arg artifact_file="$filename" \
		--build-arg repo="$repo" \
		-f ../Dockerfile-artifacts .

		echo Let us see the contents of the image
		docker create --name=temp ghcr.io/$GHCR_USER/$filename:v1 /bin/bash
		docker export temp | tar -t
		docker rm temp

		read -p "Do you want to push the $filename to ghcr? (y/n): " answer
		if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
			# Push to GHCR
			docker push ghcr.io/$GHCR_USER/$filename:v1
			# Remove image after pushing
			docker rmi ghcr.io/$GHCR_USER/$filename:v1
		else
			DIM=$(docker images -q ghcr.io/$GHCR_USER/$filename:v1)
			echo You have an image created $DIM
			echo -e "You shall remove it after use\n 'docker rmi $DIM'"
		fi
	done
	popd
elif [[ $1 == install ]]; then
	test -d ./$artifacts_download_dir || mkdir -p ./$artifacts_download_dir
	pushd $artifacts_download_dir

	# Artifacts to download can be seen on github. Here have to assume something. 
	artifacts_to_pull=(artifacts.tar.xz)

	for artifact in ${artifacts_to_pull[@]}; do
		echo "Creating ./$DIR if doesn't exist"
		docker pull ghcr.io/${GHCR_USER}/${artifact}:v1
		docker create --name tmp ghcr.io/${GHCR_USER}/${artifact}:v1 /bin/bash
		# see the content
		docker export tmp | tar -t
		docker cp tmp:/${artifact} .
		docker rm tmp
	done
	popd
else
	cat <<- EOF
	$0 <publish> <install>
	EOF
fi

