#!/bin/bash
# Clone fabric git repository
#############################
echo "Fabric Images"
cd $GOPATH/src/github.com/hyperledger/fabric
#FABRIC_COMMIT=$(git log -1 --pretty=format:"%h")
make docker && make native

# Clone fabric-ca git repository
################################
echo "Ca Images"
CA_REPO_NAME=fabric-ca
cd  $GOPATH/src/github.com/hyperledger/
if [ ! -d "$CA_REPO_NAME" ]; then
  git clone --depth=1 https://github.com/hyperledger/$CA_REPO_NAME.git
  #CA_COMMIT=$(git log -1 --pretty=format:"%h")
else
  # Previously cloned, so ask user if they want to get latest:
  echo "Using previously cloned fabric-ca. If you wish to get the latest fabric-ca, then execute:"
  echo "cd $GOPATH/src/github.com/hyperledger/$CA_REPO_NAME && git pull && make docker"
fi
cd $CA_REPO_NAME
make docker
echo "List of all Images"
docker images | grep hyperledger

################################
# create genesis block and channel creation transaction files for OTE tests

# export ORDERER_GENERAL_GENESISMETHOD=file
# export ORDERER_GENERAL_GENESISFILE=$GOPATH/src/github.com/hyperledger/fabric/genesisInsecureKafka.block
export PROFILENAME=SampleInsecureKafka

cd $GOPATH/src/github.com/hyperledger/fabric
make configtxgen
#configtxgen -profile $PROFILENAME -outputBlock genesis.block
configtxgen -profile $PROFILENAME -outputBlock genesisInsecureKafka.block

configtxgen -profile $PROFILENAME -channelID testchan000 -outputCreateChannelTx testchan000.tx
configtxgen -profile $PROFILENAME -channelID testchan001 -outputCreateChannelTx testchan001.tx
configtxgen -profile $PROFILENAME -channelID testchan002 -outputCreateChannelTx testchan002.tx

# The .tx files will be used by each test to create channels after the network is launched, such as:
#   peer channel create -c test-chan.000 -f test-chan.000.tx
#   peer channel create -c test-chan.001 -f test-chan.001.tx
#   peer channel create -c test-chan.002 -f test-chan.002.tx
