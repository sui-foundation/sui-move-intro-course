# Transfer Policy and Buy from Kiosk

In this section, we will learn how to create a `TransferPolicy` and use it to enforce rules the buyers must comply before the purchased item is owned by them.

## `TransferPolicy`

### Create a `TransferPolicy`

`TransferPolicy` for type `T` must be created for that type `T` to be tradeable in the Kiosk system. `TransferPolicy` is a shared object acting as a central authority enforcing everyone to check their purchase is valid against the defined policy before the purchased item is transferred to the buyers.

```move
use sui::transfer_policy::{Self, TransferRequest, TransferPolicy, TransferPolicyCap};
use sui::package::{Self, Publisher};

public struct KIOSK has drop {}

fun init(witness: KIOSK, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    transfer::public_transfer(publisher, ctx.sender());
}

#[allow(lint(share_owned, self_transfer))]
/// Create new policy for type `T`
public fun new_policy(publisher: &Publisher, ctx: &mut TxContext) {
    let (policy, policy_cap) = transfer_policy::new<TShirt>(publisher, ctx);
    transfer::public_share_object(policy);
    transfer::public_transfer(policy_cap, ctx.sender());
}
```

Create a `TransferPolicy<T>` requires the proof of publisher `Publisher` of the module comprising `T`. This ensures only the creator of type `T` can create `TransferPolicy<T>`. There are 2 ways to create the policy:

- Use `transfer_policy::new()` to create new policy, make the `TransferPolicy` shared object and transfer the `TransferPolicyCap` to the sender by using `sui::transfer`.

```bash
sui client call --package $KIOSK_PACKAGE_ID --module kiosk --function new_policy --args $KIOSK_PUBLISHER
```

- Use `entry transfer_policy::default()` to automatically do all above steps for us.

You should already receive the `Publisher` object when publish the package. Let's export it for later use.

```bash
export KIOSK_PUBLISHER=<Publisher object ID>
```

You should see the newly created `TransferPolicy` object and `TransferPolicyCap` object in the terminal. Let's export it for later use.

```bash
export KIOSK_TRANSFER_POLICY=<TransferPolicy object ID>
export KIOSK_TRANSFER_POLICY_CAP=<TransferPolicyCap object ID>
```

### Implement Fixed Fee Rule

`TransferPolicy` doesn't enforce anything without any rule, let's learn how to implement a simple rule in a separated module to enforce users to pay a fixed royalty fee for a trade to succeed.

_💡Note: There is a standard approach to implement the rules. Please checkout the [rule template here](../example_projects/kiosk/sources/dummy_policy.move)_

#### Rule Witness & Rule Config

```move
module kiosk::fixed_royalty_rule;

/// The `amount_bp` passed is more than 100%.
const EIncorrectArgument: u64 = 0;
/// The `Coin` used for payment is not enough to cover the fee.
const EInsufficientAmount: u64 = 1;

/// Max value for the `amount_bp`.
const MAX_BPS: u16 = 10_000;

/// The Rule Witness to authorize the policy
public struct Rule has drop {}

/// Configuration for the Rule
public struct Config has store, drop {
    /// Percentage of the transfer amount to be paid as royalty fee
    amount_bp: u16,
    /// This is used as royalty fee if the calculated fee is smaller than `min_amount`
    min_amount: u64,
}
```

`Rule` represents a witness type to add to `TransferPolicy`, it helps to identify and distinguish between multiple rules adding to one policy. `Config` is the configuration of the `Rule`, as we implement fixed royaltee fee, the settings should include the percentage we want to deduct out of original payment.

#### Add Rule to TransferPolicy

```move
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
    transfer_policy::add_rule(
        Rule {},
        policy,
        cap,
        Config { amount_bp, min_amount },
    )
}
```

We use `transfer_policy::add_rule()` to add the rule with its configuration to the policy.

Let's execute this function from the client to add the `Rule` to the `TransferPolicy`, otherwise, it is disabled. In this example, we configure the percentage of royalty fee is `0.1%` ~ `10 basis points` and the minimum amount royalty fee is `100 MIST`.

```bash
sui client call --package $KIOSK_PACKAGE_ID --module fixed_royalty_rule --function add --args $KIOSK_TRANSFER_POLICY $KIOSK_TRANSFER_POLICY_CAP 10 100 --type-args $KIOSK_PACKAGE_ID::kiosk::TShirt
```

#### Satisfy the Rule

```move
/// Buyer action: Pay the royalty fee for the transfer.
public fun pay<T: key + store>(
    policy: &mut TransferPolicy<T>,
    request: &mut TransferRequest<T>,
    payment: Coin<SUI>,
) {
    let paid = transfer_policy::paid(request);
    let amount = fee_amount(policy, paid);

    assert!(payment.value() == amount, EInsufficientAmount);

    transfer_policy::add_to_balance(Rule {}, policy, payment);
    transfer_policy::add_receipt(Rule {}, request)
}

/// Helper function to calculate the amount to be paid for the transfer.
/// Can be used dry-runned to estimate the fee amount based on the Kiosk listing price.
public fun fee_amount<T: key + store>(
    policy: &TransferPolicy<T>,
    paid: u64,
): u64 {
    let config: &Config = transfer_policy::get_rule(Rule {}, policy);
    let mut amount = (
        ((paid as u128) * (config.amount_bp as u128) / 10_000) as u64,
    );

    // If the amount is less than the minimum, use the minimum
    if (amount < config.min_amount) {
        amount = config.min_amount
    };

    amount
}
```

We need a helper `fee_amount()` to calculate the royalty fee given the policy and the payment amount. We use `transfer_policy::get_rule()` to enquire the configuration and use it for fee calculation.

`pay()` is a function that users must call themselves to fulfill the `TransferRequest` (described in the next section) before `transfer_policy::confirm_request()`. `transfer_policy::paid()` gives us original payment of the trade represented by `TransferRequest`. After royalty fee calculation, we will add the fee to the policy through `transfer_policy::add_to_balance()`, any fee collected by the policy is accumulated here and `TransferPolicyCap` owner can withdraw later. Last but not least, we use `transfer_policy::add_receipt()` to flag the `TransferRequest` that this rule is passed and ready to be confirmed with `transfer_policy::confirm_request()`.

## Buy Item from Kiosk

```move
use sui::transfer_policy::{Self, TransferRequest, TransferPolicy};

/// Buy listed item
public fun buy(
    kiosk: &mut Kiosk,
    item_id: object::ID,
    payment: Coin<SUI>,
): (TShirt, TransferRequest<TShirt>) {
    kiosk.purchase(item_id, payment)
}

/// Confirm the TransferRequest
public fun confirm_request(
    policy: &TransferPolicy<TShirt>,
    req: TransferRequest<TShirt>,
) {
    policy.confirm_request(req);
}
```

When buyers buy the asset by using `kiosk::purchase()` API, an item is returned alongside with a `TransferRequest`. `TransferRequest` is a hot potato forcing us to consume it through `transfer_policy::confirm_request()`. `transfer_policy::confirm_request()`'s job is to verify whether all the rules configured and enabled in the `TransferPolicy` are complied by the users. If one of the enabled rules are not satisfied, then `transfer_policy::confirm_request()` throws error leading to the failure of the transaction. As a consequence, the item is not under your ownership even if you tried to transfer the item to your account before `transfer_policy::confirm_request()`.

_💡Note: The users must compose a PTB with all necessary calls to ensure the TransferRequest is valid before `confirm_request()` call._

The flow can be illustrated as follow:

_Buyer -> `kiosk::purchase()` -> `Item` + `TransferRequest` -> Subsequent calls to fulfill `TransferRequest` -> `transfer_policy::confirm_request()` -> Transfer `Item` under ownership_

## Kiosk Full Flow Example

Recall from the previous section, the item must be placed inside the kiosk, then it must be listed to become sellable. Assuming the item is already listed with price `10_000 MIST`, let's export the listed item as terminal variable.

```bash
export KIOSK_TSHIRT=<Object ID of the listed TShirt>
```

Let's build a PTB to execute a trade. The flow is straightforward, we buy the listed item from the kiosk, the item and `TransferRequest` is returned, then, we call `fixed_royalty_fee::pay` to fulfill the `TransferRequest`, we confirm the `TransferRequest` with `confirm_request()` before finally transfer the item to the buyer.

```bash
sui client ptb \
--assign price 10000 \
--split-coins gas "[price]" \
--assign coin \
--move-call $KIOSK_PACKAGE_ID::kiosk::buy @$KIOSK @$KIOSK_TSHIRT coin.0 \
--assign buy_res \
--move-call $KIOSK_PACKAGE_ID::fixed_royalty_rule::fee_amount "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" @$KIOSK_TRANSFER_POLICY price \
--assign fee_amount \
--split-coins gas "[fee_amount]"\
--assign coin \
--move-call $KIOSK_PACKAGE_ID::fixed_royalty_rule::pay "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" @$KIOSK_TRANSFER_POLICY buy_res.1 coin.0 \
--move-call $KIOSK_PACKAGE_ID::kiosk::confirm_request  @$KIOSK_TRANSFER_POLICY buy_res.1 \
--move-call 0x2::transfer::public_transfer "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" buy_res.0 <buyer address> \

```
