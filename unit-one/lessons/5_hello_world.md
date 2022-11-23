# Contract Publishing and Hello World Demo

## The Complete Sample Project

You can find the complete [Hello World project here](https://github.com/sui-foundation/sui-move-intro-course/tree/main/unit-one/sample_project_1). 

## Publishing the Contract

We will use the Sui CLI to publish the package to the Sui network. You can publish it to either the Sui devnet, testnet or 
the local node. Just set the Sui CLI to the appropriate network and have enough tokens on the respective network to pay for gas. 

The Sui CLI command for publish the package is the following:

```
sui client publish --path <absolute local path to the Sui Move package> --gas-budget 30000
```

