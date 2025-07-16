# Kiosk Basic Usage

## Create Kiosk

Let's first deploy the example kiosk smart contract and export the package ID for later use.

```bash
export KIOSK_PACKAGE_ID=<Package ID of example kiosk smart contract>
```

```move
module kiosk::kiosk;
use sui::kiosk::{Self, Kiosk, KioskOwnerCap};

#[allow(lint(share_owned, self_transfer))]
/// Create new kiosk
public fun new_kiosk(ctx: &mut TxContext) {
    let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
    transfer::public_share_object(kiosk);
    transfer::public_transfer(kiosk_owner_cap, ctx.sender());
}
```

There are 2 ways to create a new kiosk:

1. Use `kiosk::new()` to create new kiosk but we have to make the `Kiosk` shared object and transfer the `KioskOwnerCap` to the sender ourselves by using `sui::transfer`.

```bash
sui client call --package $KIOSK_PACKAGE_ID --module kiosk --function new_kiosk
```

2. Use `entry kiosk::default()` to automatically do all above steps for us.

You can export the newly created `Kiosk` and its `KioskOwnerCap` for later use.

```bash
export KIOSK=<Object id of newly created Kiosk>
export KIOSK_OWNER_CAP=<Object id of newly created KioskOwnerCap>
```

_💡Note: Kiosk is heterogeneous collection by default so that's why it doesn't need type parameter for their items_

## Place Item inside Kiosk

```move
public struct TShirt has key, store {
    id: UID,
}

public fun new_tshirt(ctx: &mut TxContext): TShirt {
    TShirt {
        id: object::new(ctx),
    }
}

/// Place item inside kiosk
public fun place(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: TShirt) {
    kiosk.place(cap, item)
}
```

We can use `kiosk::place()` API to place an item inside kiosk. Remember that only the Kiosk Owner can have access to this API.

## Withdraw Item from Kiosk

```move
/// Withdraw item from Kiosk
public fun withdraw(
    kiosk: &mut Kiosk,
    cap: &KioskOwnerCap,
    item_id: object::ID,
): TShirt {
    kiosk.take(cap, item_id)
}
```

We can use `kiosk::take()` API to withdraw an item from kiosk. Remember that only the Kiosk Owner can have access to this API.

## List Item for Sale

```move
/// List item for sale
public fun list(
    kiosk: &mut Kiosk,
    cap: &KioskOwnerCap,
    item_id: object::ID,
    price: u64,
) {
    kiosk.list<TShirt>(cap, item_id, price)
}
```

We can use `kiosk::list()` API to list an item for sale. Remember that only the Kiosk Owner can have access to this API.
