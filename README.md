# Orderer Traffic Engine (OTE) - NOTE: Work In Progress to incorporate certs...

## What does OTE do?

+ This Orderer Traffic Engine (OTE) tool tests the operation of a
hyperledger fabric ordering service.
+ The focus is strictly on the orderers themselves.
No peers are involved: no endorsements or validations or committing to ledgers.
No SDK is used.

+ OTE sends transactions to
every channel on every orderer, and verifies that the correct number
of transactions and blocks are delivered on every channel from every orderer.
+ OTE generates report logs and returns
a pass/fail boolean and a resultSummaryString.

## How does OTE do it?

+ Producer clients are created to connect via
grpc ports to the orderers to concurrently send traffic until the
requested number of transactions are sent.
Each client generates unique transactions - a fraction of the total
requested number of transactions.
+ Consumer clients are created to connect via
grpc ports to the orderers to concurrently receive delivered traffic
until all batches of transactions are tallied.
OTE checks if the correct number of blocks and TXs are delivered
by all the orderers on all the channels

## Prerequisites
- <a href="https://git-scm.com/downloads" target="_blank">Git client</a>
- <a href="https://www.docker.com/products/overview" target="_blank">Docker v1.12 or higher</a>
- [Docker-Compose v1.12 or higher](https://docs.docker.com/compose/overview/)
- GO

Check your Docker and Docker-Compose versions with the following commands:
```bash
    docker version
    docker-compose version
```

### Prepare binaries and images:

-  Prepare binaries and images manually
- - Clone the fabric-test repository
```
        cd $GOPATH/src/github.com/hyperledger
        http://gerrit.hyperledger.org/r/fabric-test
```
- - Clone the fabric repository, build the binaries and images
```bash
        cd $GOPATH/src/github.com/hyperledger
        http://gerrit.hyperledger.org/r/fabric
        cd $GOPATH/src/github.com/hyperledger/fabric
        make native docker
```
- - Clone the fabric-ca repository, build the images
```bash
        cd $GOPATH/src/github.com/hyperledger/
        http://gerrit.hyperledger.org/r/fabric-ca
        cd $GOPATH/src/github.com/hyperledger/fabric-ca
        make docker
```

### Launch the Network using Network Launcher

- Refer Network Launcher [Readme](https://github.com/hyperledger/fabric-test/blob/master/tools/NL/README.md) for launching the network

## Copy the OTE directory to Fabric directory

- OTE directory should be copied from fabric-test/tools/ to fabric/ (Because of the vendoring path issue)
```bash
        cd $GOPATH/src/github.com/hyperledger/fabric-test
        cp -r tools/OTE ../fabric/
```
## Changing config.json

- OTE uses config.json to parse for profile name, channel name, tls, seek, quiet values
- - Profile: Name of the orderer profile in configtx.yaml
- - Channel: Name of the channel
- - TLS: true | false
- - seek: -2 to start from oldest block to deliver or -1 to start from newest to deliver, N >= 0 to fetch block N only
- - quiet: true (to keep quiet without printing blocks) | false (to printout delivered blocks)

## Launching OTE container

- ote-compose.yml is used to launch the OTE container by mounting the certificates and channel artifacts into the container and starts running a testcase from ote_test.go when testcase number is passed with ote-compose.yml
- If using Network Launcher for launching the network with default location i.e, $GOPATH/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen for crypto-config, channel-artifacts, current ote-compose.yml can be used as is. If not, the lines shown below for volumes, can be changed on the left side of the `:` to reflect the exact location of the certificates and channel artifacts in the ote-compose.yml
```bash
      volumes:
          - ../../../fabric-test/tools/NL/configtx.yaml:/var/hyperledger/fabric/configtx.yaml
          - ../../../fabric-test/fabric/common/tools/cryptogen/crypto-config:/var/hyperledger/fabric/artifacts
```
- Also, when using a different tool or different way for launching the fabric network, change the above the lines in the ote-compose.yml to reflect the path for crypto-config, channel-artifacts and the location of the configtx.yaml

## Environment Variables for test setup, with defaults:
```
  OTE_TXS                                      55
  OTE_CHANNELS                                 1
  OTE_ORDERERS                                 1
  OTE_MASTERSPY                                OFF
  OTE_SPY_ORDERER                              0
  OTE_PRODUCERS_PER_CHANNEL                    1
```

## Execute OTE GO Tests
- To run a particular testcase from ote_test.go, testcase number should be passed as shown below, while launching the OTE container
```bash
  cd $GOPATH/src/github.com/hyperledger/fabric/OTE
  testcase=<testcase_number> docker-compose -f ote-compose.yml up -d

```

## Collecting OTE logs

- Logs for the testcases can be seen under $GOPATH/src/github.com/hyperledger/fabric/OTE/Logs/ directory
