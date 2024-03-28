# Create Kiosk

Let's first deploy the example kiosk smart contract and export the package ID for later use.
```bash
export KIOSK_PACKAGE_ID=<Package ID of example kiosk smart contract>
```

```rust
module kiosk::kiosk {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::tx_context::{TxContext};

    #[allow(lint(share_owned, self_transfer))]
    /// Create new kiosk
    public fun new_kiosk(ctx: &mut TxContext) {
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(kiosk_owner_cap, sender(ctx));
    }
}
```

There are 2 ways to create a new kiosk:
1. Use `kiosk::new()` to create new kiosk but we have to make the `Kiosk` shared object and transfer the `KioskOwnerCap` to the sender ourselves by using `sui::transfer`.
```bash
sui client call --package $KIOSK_PACKAGE_ID --module kiosk --function new_kiosk --gas-budget 10000000
```
2. Use `entry kiosk::default()` to automatically do all above steps for us.

You can export the newly created `Kiosk` and its `KioskOwnerCap` for later use.
```bash
export KIOSK=<Object id of newly created Kiosk>
export KIOSK_OWNER_CAP=<Object id of newly created KioskOwnerCap>
```

_💡Note: Kiosk is heterogenous collection by default so that's why it doesn't need type parameter for their items_
