module locked_coin::locked_coin_df;

use sui::balance::{Self, Balance};
use sui::clock::{Self, Clock};
use sui::coin::{Self, TreasuryCap};
use sui::coin_registry;
use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;

/// Shared object used to attach the lockers
public struct Registry has key {
    id: UID,
}

public struct LOCKED_COIN has drop {}

public struct Locker has store {
    start_date: u64,
    final_date: u64,
    original_balance: u64,
    balance: Balance<LOCKED_COIN>,
}

/// Withdraw the available vested amount assuming linear vesting
public fun withdraw_vested(
    self: &mut Registry,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let locker: &mut Locker = df::borrow_mut(&mut self.id, ctx.sender());
    let total_duration = locker.final_date - locker.start_date;
    let elapsed_duration = clock.timestamp_ms() - locker.start_date;
    let total_vested_amount = if (elapsed_duration > total_duration) {
        locker.original_balance
    } else {
        locker.original_balance * elapsed_duration / total_duration
    };
    let available_vested_amount =
        total_vested_amount - (locker.original_balance - locker.balance.value());

    transfer::public_transfer(
        coin::take(&mut locker.balance, available_vested_amount, ctx),
        ctx.sender(),
    )
}

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
    transfer::public_transfer(metadata_cap, ctx.sender());
    transfer::share_object(Registry {
        id: object::new(ctx),
    })
}

public fun locked_mint(
    treasury_cap: &mut TreasuryCap<LOCKED_COIN>,
    self: &mut Registry,
    recipient: address,
    amount: u64,
    lock_up_duration: u64,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let coin = treasury_cap.mint(amount, ctx);
    let start_date = clock.timestamp_ms();
    let final_date = start_date + lock_up_duration;

    df::add(
        &mut self.id,
        recipient,
        Locker {
            start_date,
            final_date,
            original_balance: amount,
            balance: coin.into_balance(),
        },
    );
}
