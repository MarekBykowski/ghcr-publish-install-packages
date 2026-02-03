#!/bin/bash

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

artifacts_to_push="avery_qemu-docker.zip apciexactor-2.5c.cxl.tar.gz aqcxl_sim-2023_1215.tar.gz avery_pli-2023_1128.tar.gz vcsmx.tar.gz core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 verdi.tar.gz"
#artifacts_to_push="avery_qemu-docker.zip"
for artifact in ${artifacts_to_push}; do
	test -f ./artifacts/$artifact || echo "./artifacts/$artifact doesn't exist!"
	ls ./artifacts/$artifact

	filename=$(basename "$artifact")

	echo "Pushing $filename as $filename:v1"

	# Build Docker image
	docker build -t ghcr.io/$GHCR_USER/$filename:v1 \
	--build-arg artifact_file="artifacts/$filename" \
	-f Dockerfile-artifacts .

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

