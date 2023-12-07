# Clock and Locked Coin Example

In the second fungible token example, we will introduce how to obtain time on-chain in Sui, and how to utilize that to implement a vesting mechanism for a coin. 

## Clock 

Sui Framework has a native [clock module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/clock.md) that makes timestamps available in Move smart contracts. 

The main method that you will need to access is the following: 

```
public fun timestamp_ms(clock: &clock::Clock): u64
```

the [`timestamp_ms`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/clock.md#function-timestamp_ms) function returns the current system timestamp, as a running total of milliseconds since an arbitrary point in the past.

The [`clock`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/clock.md#0x2_clock_Clock) object has a unique identifier, `0x6`, that needs to be passed into function calls using it as one of the inputs. 

## Locked Coin

Now that we know how to access time on-chain through `clock`, implementing a vesting fungible token is relatively straight forward. 

