// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// Modified from https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/nfts/sources/marketplace.move

module marketplace::marketplace;

use sui::bag::{Self, Bag};
use sui::coin::Coin;
use sui::dynamic_object_field as dof;
use sui::event;
use sui::table::{Self, Table};

/// For when amount paid does not match the expected.
const EAmountIncorrect: u64 = 0;
/// For when someone tries to delist without ownership.
const ENotOwner: u64 = 1;

/// A shared Marketplace. One instance accepts only one Coin type for all listings.
public struct Marketplace<phantom COIN> has key {
    id: UID,
    items: Bag,
    payments: Table<address, Coin<COIN>>,
}

/// A single listing: listed item (as dynamic object field) and price in Coin<COIN>.
public struct Listing has key, store {
    id: UID,
    ask: u64,
    owner: address,
}

/// Key for the single dynamic object field on a Listing (the listed item).
public struct ListingItemKey() has copy, drop, store;

/// Emitted when an item is listed.
public struct ItemListed has copy, drop {
    marketplace_id: ID,
    item_id: ID,
    ask: u64,
    owner: address,
}

/// Emitted when an item is delisted.
public struct ItemDelisted has copy, drop {
    marketplace_id: ID,
    item_id: ID,
}

/// Emitted when an item is purchased.
public struct ItemPurchased has copy, drop {
    marketplace_id: ID,
    item_id: ID,
    buyer: address,
    amount: u64,
}

/// Emitted when a seller takes profits.
public struct ProfitsTaken has copy, drop {
    marketplace_id: ID,
    owner: address,
    amount: u64,
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
        id: object::new(ctx),
        ask,
        owner: ctx.sender(),
    };

    dof::add(&mut listing.id, ListingItemKey(), item);
    marketplace.items.add(item_id, listing);
    event::emit(ItemListed {
        marketplace_id: object::id(marketplace),
        item_id,
        ask,
        owner: ctx.sender(),
    });
}

/// Internal function to remove listing and get an item back. Only owner can do that.
fun delist<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    ctx: &TxContext,
): T {
    let Listing { mut id, owner, .. } = bag::remove(&mut marketplace.items, item_id);

    assert!(ctx.sender() == owner, ENotOwner);

    let item = dof::remove(&mut id, ListingItemKey());
    id.delete();
    event::emit(ItemDelisted {
        marketplace_id: object::id(marketplace),
        item_id,
    });
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

/// Internal function to purchase an item. Payment in Coin<COIN>. Amount must match ask.
fun buy<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    paid: Coin<COIN>,
): T {
    let Listing { mut id, ask, owner } = marketplace.items.remove(item_id);

    assert!(ask == paid.value(), EAmountIncorrect);

    if (marketplace.payments.contains(owner)) {
        marketplace.payments.borrow_mut(owner).join(paid)
    } else {
        marketplace.payments.add(owner, paid)
    };

    let item = dof::remove(&mut id, ListingItemKey());
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
    let amount = paid.value();
    let item = buy<T, COIN>(marketplace, item_id, paid);
    event::emit(ItemPurchased {
        marketplace_id: object::id(marketplace),
        item_id,
        buyer: ctx.sender(),
        amount,
    });
    transfer::public_transfer(item, ctx.sender());
}

/// Internal function to take profits from selling items on the Marketplace.
fun take_profits<COIN>(
    marketplace: &mut Marketplace<COIN>,
    ctx: &TxContext,
): Coin<COIN> {
    marketplace.payments.remove(ctx.sender())
}

#[lint_allow(self_transfer)]
/// Call [`take_profits`] and transfer Coin to the sender.
public fun take_profits_and_keep<COIN>(
    marketplace: &mut Marketplace<COIN>,
    ctx: &mut TxContext,
) {
    let coin = take_profits(marketplace, ctx);
    event::emit(ProfitsTaken {
        marketplace_id: object::id(marketplace),
        owner: ctx.sender(),
        amount: coin.value(),
    });
    transfer::public_transfer(coin, ctx.sender());
}
