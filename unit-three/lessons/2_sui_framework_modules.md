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

### `Coin` resource

The `Coin` resource will be explained fully in the following section as it requires understanding generics in Move first. 

### `TreasuryCap` resource

The `TreasuryCap` resource is a type of capability that was introduced in the previous unit; it marks the ability for the holder to mint and burn tokens in the fungible token we are creating. The implementation of `TreasuryCap` in `sui::coin` has the abilities of `store` and `key`. 

### `coin::create_currency` method

The `coin::create_currency` method creates a new currency type T as and return the TreasuryCap for T to the caller. 

Its method signature is as the following:

```
public fun create_currency<T: drop>(witness: T, decimals: u8, symbol: vector<u8>, name: vector<u8>, 
description: vector<u8>, icon_url: option::Option<url::Url>, ctx: &mut tx_context::TxContext): 
(coin::TreasuryCap<T>, coin::CoinMetadata<T>)
```

We will look at this method more closely after introducing the witness pattern. 







