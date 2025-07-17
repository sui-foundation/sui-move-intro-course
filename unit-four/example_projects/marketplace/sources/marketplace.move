// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// Modified from https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/nfts/sources/marketplace.move

module marketplace::marketplace;

use sui::bag::{Self, Bag};
use sui::coin::Coin;
use sui::dynamic_object_field as dof;
use sui::table::{Self, Table};

/// For when amount paid does not match the expected.
const EAmountIncorrect: u64 = 0;
/// For when someone tries to delist without ownership.
const ENotOwner: u64 = 1;

/// A shared `Marketplace`. Can be created by anyone using the
/// `create` function. One instance of `Marketplace` accepts
/// only one type of Coin - `COIN` for all its listings.
public struct Marketplace<phantom COIN> has key {
    id: UID,
    items: Bag,
    payments: Table<address, Coin<COIN>>,
}

/// A single listing which contains the listed item and its
/// price in [`Coin<COIN>`].
public struct Listing has key, store {
    id: UID,
    ask: u64,
    owner: address,
}

/// Create a new shared Marketplace.
public fun create<COIN>(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let items = bag::new(ctx);
    let payments = table::new<address, Coin<COIN>>(ctx);
    transfer::share_object(Marketplace<COIN> {
        id,
        items,
        payments,
    })
}

/// List an item at the Marketplace.
public fun list<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item: T,
    ask: u64,
    ctx: &mut TxContext,
) {
    let item_id = object::id(&item);
    let mut listing = Listing {
        ask,
        id: object::new(ctx),
        owner: ctx.sender(),
    };

    dof::add(&mut listing.id, true, item);
    marketplace.items.add(item_id, listing)
}

/// Internal function to remove listing and get an item back. Only owner can do
/// that.
fun delist<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    ctx: &TxContext,
): T {
    let Listing { mut id, owner, .. } = bag::remove(
        &mut marketplace.items,
        item_id,
    );

    assert!(ctx.sender() == owner, ENotOwner);

    let item = dof::remove(&mut id, true);
    id.delete();
    item
}

/// Call [`delist`] and transfer item to the sender.
public fun delist_and_take<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    ctx: &mut TxContext,
) {
    let item = delist<T, COIN>(marketplace, item_id, ctx);
    transfer::public_transfer(item, ctx.sender());
}

/// Internal function to purchase an item using a known Listing. Payment is done
/// in Coin<C>.
/// Amount paid must match the requested amount. If conditions are met,
/// owner of the item gets the payment and buyer receives their item.
fun buy<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    paid: Coin<COIN>,
): T {
    let Listing {
        mut id,
        ask,
        owner,
    } = marketplace.items.remove(item_id);

    assert!(ask == paid.value(), EAmountIncorrect);

    // Check if there's already a Coin hanging and merge `paid` with it.
    // Otherwise attach `paid` to the `Marketplace` under owner's `address`.
    if (marketplace.payments.contains(owner)) {
        marketplace.payments.borrow_mut(owner).join(paid)
    } else {
        marketplace.payments.add(owner, paid)
    };

    let item = dof::remove(&mut id, true);
    id.delete();
    item
}

/// Call [`buy`] and transfer item to the sender.
public fun buy_and_take<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    paid: Coin<COIN>,
    ctx: &mut TxContext,
) {
    transfer::public_transfer(
        buy<T, COIN>(marketplace, item_id, paid),
        ctx.sender(),
    )
}

/// Internal function to take profits from selling items on the `Marketplace`.
fun take_profits<COIN>(
    marketplace: &mut Marketplace<COIN>,
    ctx: &TxContext,
): Coin<COIN> {
    marketplace.payments.remove(ctx.sender())
}

#[lint_allow(self_transfer)]
/// Call [`take_profits`] and transfer Coin object to the sender.
public fun take_profits_and_keep<COIN>(
    marketplace: &mut Marketplace<COIN>,
    ctx: &mut TxContext,
) {
    transfer::public_transfer(
        take_profits(marketplace, ctx),
        ctx.sender(),
    )
}
