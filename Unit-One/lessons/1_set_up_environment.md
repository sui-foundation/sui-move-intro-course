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

## Configure VS Code with Move Analyzer Plug-in

1. Install [Move Analyzer plugin](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) from VS Marketplace

2. Add compatibility for Sui style wallet addresses:

    `cargo install --git https://github.com/move-language/move move-analyzer --features "address20"`

## Sui CLI Basic Usage



