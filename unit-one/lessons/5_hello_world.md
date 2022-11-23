# Contract Deployment and Hello World Demo

## The Complete Hello World Sample Project

You can find the complete [Hello World project here](https://github.com/sui-foundation/sui-move-intro-course/tree/main/unit-one/sample_project_1). 

## Deploying the Contract

We will use the Sui CLI to deploy the package to the Sui network. You can deploy it to either the Sui devnet, testnet or 
the local node. Just set the Sui CLI to the respective network and have enough tokens to pay for gas. 

The Sui CLI command for deploying the package is the following:

```
sui client publish --path <absolute local path to the Sui Move package> --gas-budget 30000
```

The output should look something like this if the contract was successfully deployd:

![Publish Output](https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-one/images/publish.png)

The object ID under the `Created Objects` section is the object ID of the Hello World package we just published.

Let's export that to a variable. 

```
export PACKAGE_ID = <package object ID from previous output>
```

## 



