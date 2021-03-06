#!/bin/bash
#
#*******************************************************************************
# Copyright (c) 2019 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

# Pushes the Nginx sidecar image up to the specified registry

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <registry-to-push-sidecar-to>"
    exit 1
fi

REGISTRY=$1
BASE_DIR=$(dirname pwd)

docker tag codewind-che-sidecar $REGISTRY/codewind-che-sidecar
docker push $REGISTRY/codewind-che-sidecar

# Create the meta.yaml for the Sidecar container
mkdir -p $BASE_DIR/publish/codewind-sidecar/latest
cat <<EOF > publish/codewind-sidecar/latest/meta.yaml
id: codewind-sidecar
apiVersion: v2
version: latest
type: Che Plugin
name: CodewindPlugin
title: CodewindPlugin
description: Enables iterative development and deployment in Che
icon: https://raw.githubusercontent.com/eclipse/codewind-vscode/master/dev/res/img/codewind.png
publisher: Eclipse
repository: https://github.com/eclipse/codewind-che-plugin
category: Other
firstPublicationDate: "2019-05-30"
latestUpdateDate: "$(date '+%Y-%m-%d')"
spec:
  containers:
  - name: codewind-che-sidecar
    image: $REGISTRY/codewind-che-sidecar:latest
    volumes:
      - mountPath: "/projects"
        name: projects
    ports:
      - exposedPort: 9090

EOF

# Create the meta.yaml for the Theia extension
mkdir -p $BASE_DIR/publish/codewind-theia/latest
cat <<EOF > publish/codewind-theia/latest/meta.yaml
apiVersion: v2
publisher: Eclipse
name: codewind-plugin
version: latest
type: VS Code extension
displayName: Codewind VS Code Extension
title: Codewind Extension for VS Code
description: Codewind Extension for Theia
icon: https://raw.githubusercontent.com/eclipse/codewind-vscode/master/dev/res/img/codewind.png
repository: http://github.com/eclipse/codewind-vscode/
category: Other
firstPublicationDate: "2019-05-30"
latestUpdateDate: "$(date '+%Y-%m-%d')"
spec:
  extensions:
    - http://download.eclipse.org/codewind/milestone/0.2.0/codewind-theia-0.2.0.vsix

EOF

echo "Published the codewind-sidecar and codewind-theia meta.yamls under $BASE_DIR/publish"
