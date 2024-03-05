# Sui Kiosk

Now we have learned the basics of **Programmable Transaction Block** and **Hot Potato Design Pattern**, it is much easier for us to understand the mechanism behind **Sui Kiosk**. Let's get started

## What is Sui Kiosk?

We're probably familiar to some sort of kiosks in real life. It can be a stall in a tourist shopping mall selling you merchantdise, apparels or any local souvenirs. It can be in a form of big screen displaying you digital images of the products you're interested in. They may all come with different forms and sizes but they have one common trait: _they sell something and display their wares openly for passersby to browse and engage with_

**Sui Kiosk** is the digital version of these types of kiosk but for digital assets and collectibles. Sui Kiosk is a _decentralized system for onchain commerce applications on Sui_. Practically, Kiosk is a part of the Sui framework, and it is native to the system and available to everyone out of the box.

## Why Sui Kiosk?

Sui Kiosk is created to answer these needs:

- Can we list an item on marketplace and continue using it?
- Is there a way to create a “safe” for collectibles?
- Can we build an onchain system with custom logic for transfer management?
- How to favor creators and guarantee royalties?
- Can we avoid centralization of traditional marketplaces?

## Main Components

Sui Kiosk consists these 2 main components:

- `Kiosk` + `KioskOwnerCap`: `Kiosk` is the safe that will store our assets and display them for selling, it is implemented as a shared object allowing interactions between multiple parties. Each `Kiosk` will have a corresponding Kiosk Owner whoever holding the `KioskOwnerCap`. The Kiosk Owner still have the _logical ownership_ over their assets even when they are _physically_ placed in the kiosk.
- `TransferPolicy` + `TransferPolicyCap`: `TransferPolicy` is a shared object defines the conditions in which the assets can be traded or sold. Each `TransferPolicy` consists a set of _rules_, with each rule specifies the requirements every trade must sastify. Rules can be enabled or disabled from the `TransferPolicy` by whoever owning the `TransferOwnerCap`. Greate example of `TransferPolicy`'s rule is the royalty fees guarantee.

## Sui Kiosk Users

Sui Kiosk use-cases is centered around these 3 types of users:

- Kiosk Owner (Seller/KO): One must own the `KioskOwnerCap` to become the Kiosk Owner. KO can:
  - Place their assets in kiosk.
  - Withdraw the assets in kiosk if they're not _locked_.
  - List assets for sale.
  - Withdraw profits from sales.
  - Borrow and mutate owned assets in kiosk.
- Buyer: Buyer can be anyone who's willing to purchase the listed items. The buyers must satisfy the `TransferPolicy` for the trade to be considered successful.
- Creator: Creator is a party that creates and controls the `TransferPolicy` for a single type. For example, authors of SuiFrens collectibles are the creators of `SuiFren<Capy>` type and act as creators in the Sui Kiosk system. Creators can:
  - Set any rules for trades.
  - Set multiple tracks of rules.
  - Enable or disable trades at any moment with a policy.
  - Enforce policies (eg royalties) on all trades.
  - All operations are affected immediately and globally.

## Asset States in Sui Kiosk

When you add an asset to your kiosk, it has one of the following states:

- `PLACED` - an item is placed inside the kiosk. The Kiosk Owner can withdraw it and use it directly, borrow it (mutably or immutably), or list an item for sale.
- `LOCKED` - an item is placed and locked in the kiosk. The Kiosk Owner can't withdraw a _locked_ item from kiosk, but you can borrow it mutably and list it for sale.
- `LISTED` - an item in the kiosk that is listed for sale. The Kiosk Owner can’t modify an item while listed, but you can borrow it immutably or delist it, which returns it to its previous state.

_💡Note: there is another state called `LISTED EXCLUSIVELY`, which is not covered in this unit and will be covered in the future in advanced section_

## Sui Kiosk Usage

### Create Kiosk

```rust
module kiosk::kiosk {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::tx_context::{TxContext};

    /// Create new kiosk
    public fun new_kiosk(ctx: &mut TxContext): (Kiosk, KioskOwnerCap) {
        kiosk::new(ctx)
    }
}
```

There are 2 ways to create a new kiosk:

- Use `kiosk::new()` to create new kiosk but we have to make the `Kiosk` shared object and transfer the `KioskOwnerCap` to the sender ourselves by using `sui::transfer` in the same PTB.
- Use `kiosk::default()` to automatically do all above steps for us. However, remeber that `kiosk::default()` is an entry function, so we can't include other calls in the same PTB.

_💡Note: Kiosk is heterogenous collection by default so that's why it doesn't need type parameter for their items_

### Place Item inside Kiosk

```rust
struct TShirt has key, store {
    id: UID,
}

public fun new_tshirt(ctx: &mut TxContext): TShirt {
    TShirt {
        id: object::new(ctx),
    }
}

/// Place item inside kiosk
public fun place(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: TShirt) {
    kiosk::place(kiosk, cap, item)
}
```

We can use `kiosk::place()` API to place an item inside kiosk. Remember that only the Kiosk Owner can have access to this API.

### Withdraw Item from Kiosk

```rust
/// Withdraw item from Kiosk
public fun withdraw(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): TShirt {
    kiosk::take(kiosk, cap, item_id)
}
```

We can use `kiosk::take()` API to withdraw an item from kiosk. Remember that only the Kiosk Owner can have access to this API.

### List Item for Sale

```rust
/// List item for sale
public fun list(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID, price: u64) {
    kiosk::list<TShirt>(kiosk, cap, item_id, price)
}
```

We can use `kiosk::list()` API to list an item for sale. Remember that only the Kiosk Owner can have access to this API.

### Buy Item from Kiosk

```rust
use sui::transfer_policy::{Self, TransferRequest, TransferPolicy};

/// Buy listed item
public fun buy(kiosk: &mut Kiosk, item_id: object::ID, payment: Coin<SUI>): (TShirt, TransferRequest<TShirt>){
    kiosk::purchase(kiosk, item_id, payment)
}

/// Confirm the TransferRequest
public fun confirm_request(policy: &TransferPolicy<TShirt>, req: TransferRequest<TShirt>) {
    transfer_policy::confirm_request(policy, req);
}
```

When buyers buy the asset by using `kiosk::purchase()` API, an item is returned alongside with a `TransferRequest`. `TransferRequest` is a hot potato forcing us to consume it through `transfer_policy::confirm_request()`. `confirm_request()`'s job is to verify whether all the rules configured and enabled in the `TransferPolicy` are complied by the users. If one of the enabled rules are not satisfied, then `confirm_request()` throws error leading to the failure of the transaction. As a consequence, the item is not under your ownership even if you tried to transfer the item to your account before `confirm_request()`.

_💡Note: The users must compose a PTB with all necessary calls to ensure the TransferRequest is valid before `confirm_request()` call._

The flow can be illustrated as follow:

_Buyer -> `kiosk::purchase()` -> `Item` + `TransferRequest` -> Subsequent calls to fulfill `TransferRequest` -> `transfer_policy::confirm_request()` -> Transfer `Item` under ownership_

### Create a `TransferPolicy`

`TransferPolicy` for type `T` must be created for that type `T` to be tradeable in the Kiosk system. `TransferPolicy` is a shared object acting as a central authority so that everyone can use it to `confirm_request()`.

```rust
use sui::tx_context::{TxContext, sender};
use sui::transfer_policy::{Self, TransferRequest, TransferPolicy, TransferPolicyCap};
use sui::package::{Self, Publisher};
use sui::transfer::{Self};

struct KIOSK has drop {}

fun init(witness: KIOSK, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    transfer::public_transfer(publisher, sender(ctx));
}

/// Create new policy for type `T`
public fun new_policy(publisher: &Publisher, ctx: &mut TxContext): (TransferPolicy<TShirt>, TransferPolicyCap<TShirt>) {
    transfer_policy::new(publisher, ctx)
}
```

Create a `TransferPolicy<T>` requires the proof of publisher `Publisher` of the module comprising `T`. This ensures only the creator of type `T` can create `TransferPolicy<T>`. There are 2 ways to create the policy:

- Use `transfer_policy::new()` to create new policy but we have to make the `TransferPolicy` shared object and transfer the `TransferPolicyCap` to the `Publisher` ourselves by using `sui::transfer` in the same PTB.
- Use `transfer_policy::default()` to automatically do all above steps for us. However, remeber that `transfer_policy::default()` is an entry function, so we can't include other calls in the same PTB.

### Implement Fixed Fee Rule

`TransferPolicy` doesn't enforce anything without any rule, let's learn how to implement a simple rule in a separated module to enforce users to pay a fixed royalty fee for a trade to succeed.

*💡Note: There is a standard approach to implement the rules. Please checkout the [rule template here](../example_projects/kiosk/sources/dummy_policy.move)*

#### Rule Witness & Rule Config
```rust
module kiosk::fixed_royalty_rule {
    /// The `amount_bp` passed is more than 100%.
    const EIncorrectArgument: u64 = 0;
    /// The `Coin` used for payment is not enough to cover the fee.
    const EInsufficientAmount: u64 = 1;

    /// Max value for the `amount_bp`.
    const MAX_BPS: u16 = 10_000;

    /// The Rule Witness to authorize the policy
    struct Rule has drop {}

    /// Configuration for the Rule
    struct Config has store, drop {
        /// Percentage of the transfer amount to be paid as royalty fee
        amount_bp: u16,
        /// This is used as royalty fee if the calculated fee is smaller than `min_amount`
        min_amount: u64,
    }
}
```

`Rule` represents a witness type to add to `TransferPolicy`, it helps to identify and distinguish between multiple rules adding to one policy. `Config` is the configuration of the `Rule`, as we implement fixed royaltee fee, the settings should include the percentage we want to deduct out of orignal payment.

#### Add Rule to TransferPolicy

```rust
/// Function that adds a Rule to the `TransferPolicy`.
/// Requires `TransferPolicyCap` to make sure the rules are
/// added only by the publisher of T.
public fun add<T>(
    policy: &mut TransferPolicy<T>,
    cap: &TransferPolicyCap<T>,
    amount_bp: u16,
    min_amount: u64
    
) {
    assert!(amount_bp <= MAX_BPS, EIncorrectArgument);
    policy::add_rule(Rule {}, policy, cap, Config { amount_bp, min_amount })
}
```

We use `policy::add_rule()` to add the rule with its configuration to the policy.

#### Buyers Follow the Rule

```rust
/// Buyer action: Pay the royalty fee for the transfer.
public fun pay<T: key + store>(
    policy: &mut TransferPolicy<T>,
    request: &mut TransferRequest<T>,
    payment: Coin<SUI>
) {
    let paid = policy::paid(request);
    let amount = fee_amount(policy, paid);

    assert!(coin::value(&payment) == amount, EInsufficientAmount);

    policy::add_to_balance(Rule {}, policy, payment);
    policy::add_receipt(Rule {}, request)
}

/// Helper function to calculate the amount to be paid for the transfer.
/// Can be used dry-runned to estimate the fee amount based on the Kiosk listing price.
public fun fee_amount<T: key + store>(policy: &TransferPolicy<T>, paid: u64): u64 {
    let config: &Config = policy::get_rule(Rule {}, policy);
    let amount = (((paid as u128) * (config.amount_bp as u128) / 10_000) as u64);

    // If the amount is less than the minimum, use the minimum
    if (amount < config.min_amount) {
        amount = config.min_amount
    };

    amount
}
```

We need a helper `fee_amount()` to calculate the royalty fee given the policy and the payment amount. We use `policy::get_rule()` to enquire the configuration and use it for fee calculation.

`pay()` is a function that users must call themselves to fullfil the `TransferRequest` before `confirm_request()`. `policy::paid()` gives us original payment of the trade embedded in the `TransferRequest`. After royalty fee calculation, we will add the fee to the policy through `policy::add_to_balance()`, any fee collected by the policy is accumulated here and `TransferPolicyCap` owner can withdraw later. Last but not least, we use `policy::add_receipt()` to flag the `TransferRequest` that this rule is passed and ready to be confirmed with `confirm_request()`.