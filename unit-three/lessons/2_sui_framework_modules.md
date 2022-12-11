# Sui Framework

## Introduction

[The Sui Framework](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/docs) is Sui's specific implementation of the Move VM. It contains Sui's native API's including its implementation of the Move standard library, as well as Sui specific operations such as [crypto primitives](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/docs) and Sui's implementation of [data structures](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/url.md) at the framework level. 

An implementation of a fungible token in Sui will heavily leverage some of the libraries in the Sui Framework. 

## sui::coin

The main libraries used in the implementation of a fungile coin is the [`sui::coin` module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md). 

The resources or methods we will directly use for our fungible token example are:

- Resource: [Coin](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#resource-coin)
- Resource: [TreasuryCap](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#resource-treasurycap)
- Method: [coin::create_currency](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-create_currency)






