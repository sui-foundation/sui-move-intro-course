// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example coin with a trusted manager responsible for minting/burning
/// (e.g., stablecoin)
/// By convention, modules defining custom coin types use upper case names, in
/// contrast to ordinary modules, which use camel case.
module fungible_tokens::managed;

use sui::coin::{Self, Coin, TreasuryCap};

/// Name of the coin. By convention, this type has the same name as its parent
/// module
/// and has no fields. The full type of the coin defined by this module will be
/// `COIN<MANAGED>`.
public struct MANAGED has drop {}

/// Register the managed currency to acquire its `TreasuryCap`. Because
/// this is a module initializer, it ensures the currency only gets
/// registered once.
fun init(witness: MANAGED, ctx: &mut TxContext) {
    // Get a treasury cap for the coin and give it to the transaction sender
    let (treasury_cap, metadata) = coin::create_currency<MANAGED>(
        witness,
        2,
        b"MANAGED",
        b"MNG",
        b"",
        option::none(),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury_cap, ctx.sender())
}

/// Manager can mint new coins
public fun mint(
    treasury_cap: &mut TreasuryCap<MANAGED>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    treasury_cap.mint_and_transfer(amount, recipient, ctx)
}

/// Manager can burn coins
public fun burn(treasury_cap: &mut TreasuryCap<MANAGED>, coin: Coin<MANAGED>) {
    treasury_cap.burn(coin);
}

#[test_only]
/// Wrapper of module initializer for testing
public fun test_init(ctx: &mut TxContext) {
    init(MANAGED {}, ctx)
}
