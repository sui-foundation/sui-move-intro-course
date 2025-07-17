// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module closed_loop_token::parity;

use closed_loop_token::parity_rule::{Self, ParityRule};
use sui::coin::{Self, Coin, TreasuryCap};
use sui::token::{Self, TokenPolicy};

/// Name of the coin. By convention, this type has the same name as its parent
/// module and has no fields. The full type of the coin defined by this module
/// will be `COIN<PARITY>`.
public struct PARITY has drop {}

/// Register the PARITY currency to acquire its `TreasuryCap`.
/// Because this is a module initializer, it ensures the currency only gets
/// registered once.
fun init(witness: PARITY, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<PARITY>(
        witness,
        2,
        b"PARITY",
        b"MNG",
        b"",
        option::none(),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    let (mut policy, policy_cap) = token::new_policy<PARITY>(
        &treasury_cap,
        ctx,
    );
    token::add_rule_for_action<PARITY, ParityRule>(
        &mut policy,
        &policy_cap,
        b"from_coin".to_string(),
        ctx,
    );
    policy.share_policy();
    transfer::public_transfer(policy_cap, ctx.sender());
    transfer::public_transfer(treasury_cap, ctx.sender())
}

/// Example of confirming a protected action with treasury cap
public fun treasure_cap_mint_token(
    treasury_cap: &mut TreasuryCap<PARITY>,
    amount: u64,
    ctx: &mut TxContext,
) {
    let coin = treasury_cap.mint(amount, ctx);
    let (token, request) = token::from_coin(coin, ctx);
    token::confirm_with_treasury_cap(treasury_cap, request, ctx);
    token.keep(ctx)
}

/// Example of confirming a protected action with a token policy
public fun policy_mint_token(
    treasury_cap: &mut TreasuryCap<PARITY>,
    policy: &TokenPolicy<PARITY>,
    amount: u64,
    ctx: &mut TxContext,
) {
    let coin = treasury_cap.mint(amount, ctx);
    let (token, mut request) = token::from_coin(coin, ctx);
    parity_rule::verify(policy, &mut request, ctx);
    policy.confirm_request(request, ctx);
    token.keep(ctx);
}

/// Manager can mint new coins
public fun mint(
    treasury_cap: &mut TreasuryCap<PARITY>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    treasury_cap.mint_and_transfer(amount, recipient, ctx)
}

/// Manager can burn coins
public fun burn(treasury_cap: &mut TreasuryCap<PARITY>, coin: Coin<PARITY>) {
    treasury_cap.burn(coin);
}
