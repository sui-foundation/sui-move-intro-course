// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Basic token locking and vesting example for Move on Sui.
/// Part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
module locked_coin::locked_coin;

use sui::balance::Balance;
use sui::clock::Clock;
use sui::coin::{Self, TreasuryCap};
use sui::coin_registry;

// === Types ===

/// Transferable object for storing the vesting coins
public struct Locker has key {
    id: UID,
    start_date: u64,
    final_date: u64,
    original_balance: u64,
    current_balance: Balance<LOCKED_COIN>,
}

/// Witness (OTW: name matches module in ALL_CAPS)
public struct LOCKED_COIN has drop {}

// === Init ===

fun init(otw: LOCKED_COIN, ctx: &mut TxContext) {
    let (builder, treasury_cap) = coin_registry::new_currency_with_otw<LOCKED_COIN>(
        otw,
        8,
        b"LOCK".to_string(),
        b"LOCKED COIN".to_string(),
        b"".to_string(),
        b"".to_string(),
        ctx,
    );
    let metadata_cap = builder.finalize(ctx);
    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata_cap, ctx.sender())
}

// === Public ===

#[lint_allow(self_transfer)]
/// Withdraw the available vested amount assuming linear vesting
public fun withdraw_vested(
    locker: &mut Locker,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let total_duration = locker.final_date - locker.start_date;
    let elapsed_duration = clock.timestamp_ms() - locker.start_date;
    let total_vested_amount = if (elapsed_duration > total_duration) {
        locker.original_balance
    } else {
        locker.original_balance * elapsed_duration / total_duration
    };
    let available_vested_amount =
        total_vested_amount - (locker.original_balance - locker.current_balance.value());
    transfer::public_transfer(
        coin::take(&mut locker.current_balance, available_vested_amount, ctx),
        ctx.sender(),
    )
}

/// Mints and transfers a locker object with the input amount of coins and
/// specified vesting schedule
public fun locked_mint(
    treasury_cap: &mut TreasuryCap<LOCKED_COIN>,
    recipient: address,
    amount: u64,
    lock_up_duration: u64,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let coin = treasury_cap.mint(amount, ctx);
    let start_date = clock.timestamp_ms();
    let final_date = start_date + lock_up_duration;

    transfer::transfer(
        Locker {
            id: object::new(ctx),
            start_date,
            final_date,
            original_balance: amount,
            current_balance: coin.into_balance(),
        },
        recipient,
    );
}
