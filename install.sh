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

# orig from chatgpt
: << EOF
#docker pull ghcr.io/YOUR_GITHUB_USERNAME/YOUR_GITHUB_REPO/mytool:1.0.0
#docker create --name tmp mytool:1.0.0 /bin/bash
#docker cp tmp:/mytool-1.0.0.tar.gz ./mytool-1.0.0.tar.gz
#docker rm tmp
EOF

DIR=artifacts-${RANDOM}

artifacts_to_pull="avery_qemu-docker.zip apciexactor-2.5c.cxl.tar.gz aqcxl_sim-2023_1215.tar.gz avery_pli-2023_1128.tar.gz vcsmx.tar.gz core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 verdi.tar.gz"
#artifacts_to_pull="avery_qemu-docker.zip"
for artifact in ${artifacts_to_pull}; do
	echo "Creating ./$DIR if doesn't exist"
	test -d ./$DIR || mkdir -p ./$DIR
	docker pull ghcr.io/${GHCR_USER}/${artifact}:v1
	docker create --name tmp ghcr.io/${GHCR_USER}/${artifact}:v1 /bin/bash
	# see the content
	docker export tmp | tar -t
	docker cp tmp:/${artifact} ./$DIR
	docker rm tmp
done
