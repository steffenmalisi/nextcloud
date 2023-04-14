#!/bin/bash

ID_RSA_PUB_PATH=${1:-~/.ssh.id_rsa.pub}
cp "$ID_RSA_PUB_PATH" ./combustion/id_rsa.pub