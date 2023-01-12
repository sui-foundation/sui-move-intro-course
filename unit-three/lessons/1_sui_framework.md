# Sui Framework

A common use case for smart contracts is issuing custom fungible tokens (such as ERC-20 tokens on Ethereum). Let's take a look at how that can be done on Sui using the Sui Framework, and some variations on the classic fungible tokens.

## Sui Framework

[The Sui Framework](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/docs) is Sui's specific implementation of the Move VM. It contains Sui's native API's including its implementation of the Move standard library, as well as Sui specific operations such as [crypto primitives](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/groth16.md) and Sui's implementation of [data structures](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/url.md) at the framework level. 

An implementation of a fungible token in Sui will heavily leverage some of the features of the Sui Framework. 

## `sui::coin`

The main library we will use to implement a fungile coin is the [`sui::coin` module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md). 

The resources or methods we will directly use for our fungible token example are:

- Resource: [TreasuryCap](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#resource-treasurycap)
- Resource: [Coin](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#resource-coin)
- Method: [coin::create_currency](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-create_currency)

### `TreasuryCap` Resource

The `TreasuryCap` resource is a type of [Capability](../../unit-two/lessons/6_capability_design_pattern.md); it marks the ability for the holder to mint and burn tokens in the custom token we are creating. 

The implementation of `TreasuryCap` in `sui::coin` has the abilities of `store` and `key`, so it is a Move asset and can be transferred between accounts. 

### `Coin` Resource

```rust
    struct Coin<T> has store, key
```

The `Coin` resource is a type with the abilities `store` and `key`, and it takes in a generic type parameter `T`. We will revisit this type after understanding how generics work in Move. 

### `coin::create_currency` Method

The `coin::create_currency` method creates a new currency type T and return the TreasuryCap for T to the caller. 

Its method signature is as the following:

```rust
    public fun create_currency<T: drop>(witness: T, decimals: u8, symbol: vector<u8>, name: vector<u8>, 
    description: vector<u8>, icon_url: option::Option<url::Url>, ctx: &mut tx_context::TxContext): 
    (coin::TreasuryCap<T>, coin::CoinMetadata<T>)
```

We will look at this method more closely after introducing the witness pattern. 





