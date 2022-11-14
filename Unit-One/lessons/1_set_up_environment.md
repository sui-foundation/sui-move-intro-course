# Setup Development Environment

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

2. Pull Sui image for Sui Move intro course 

    `placeholder`

3. Start the Docker image:

    `placeholder`

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

- Mint a demo NFT on the current network: `sui client create-example-nft`

![This is an image](https://github.com/hyd628/sui-move-intro-course/blob/main/Unit-One/images/demo-nft.png)

## Get Devnet Tokens

1. [Join Sui Discord](https://discord.gg/sui)
2. Complete verification steps
3. Enter #devnet-faucet channel
4. Type `!faucet <WALLET ADDRESS>`

## Get Testnet Tokens




