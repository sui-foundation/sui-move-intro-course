# Setup Development Environment

Welcome to the Sui Move introduction course. In this first unit, we will walk you through the process of setting up the development environment for working with Sui Move, and create a basic Hello World project as a gentle introduction into the world of Sui.

## Install Sui Binaries Locally

[Reference Page](https://docs.sui.io/build/install#install-sui-binaries)

1. [Install prerequisites](https://docs.sui.io/build/install#prerequisites) (dependent on OS) 

2. Install Sui binaries
    
    `cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui`

3. Check binaries are installed successfully:

    `sui --version`

    You should see the version number in the terminal if sui binaries were installed successfully. 

## Using a Docker Image with Pre-installed Sui Binaries

1. [Install Docker](https://docs.docker.com/get-docker/)

2. Pull the premade Docker image for the Sui Move intro course 

    `docker pull hyd628/sui-move-intro-course:latest`

3. Start and shell into the Docker container:

    `docker run --entrypoint /bin/sh -itd hyd628/sui-move-intro-course:latest`
    `docker exec -it <container ID> bash`

*💡Note: If the above Docker image is not compatible with your CPU architecture, you can start with a base [Rust](https://hub.docker.com/_/rust) Docker image appropriate for your CPU architecture, and install the Sui binaries and prerequisites as described above.*

## Configure VS Code with Move Analyzer Plug-in

1. Install [Move Analyzer plugin](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) from VS Marketplace

2. Add compatibility for Sui style wallet addresses:

    `cargo install --git https://github.com/move-language/move move-analyzer --features "address20"`

## Sui CLI Basic Usage

[Reference Page](https://docs.sui.io/build/cli-client)

### Managing Networks

- Switching network: `sui client switch --env [network alias]`
- Default network aliases: 
    - localnet: http://0.0.0.0:9000
    - devnet: https://fullnode.devnet.sui.io:443
- List all current network aliases: `sui client envs`
- Add new network alias: `sui client new-env --alias <ALIAS> --rpc <RPC>`

### Check Active Address and Gas Objects

- Check current addresses in key store: `sui client addresses`
- Check active-address: `sui client active-address`
- List all controlled gas objects: `sui client gas`

### Mint a Demo NFT

- Mint a demo NFT on the current network: `sui client create-example-nft`. You should see something similar to the following output:

![Demo NFT](../images/demo-nft.png)

## Get Devnet Sui Tokens

1. [Join Sui Discord](https://discord.gg/sui)
2. Complete verification steps
3. Enter `#devnet-faucet` channel
4. Type `!faucet <WALLET ADDRESS>`

## Get Testnet Sui Tokens




