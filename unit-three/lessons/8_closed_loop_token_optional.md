#  (Optional) Closed Loop Token Standard

## Relationship with `Coin` and `Balance`

![Trinity](../images/trinity.png)

## Actions

### Public

- `token::keep` - send a Token to the transaction sender
- `token::join` - join two Tokens
- `token::split` - split a Token into two, specify the amount to split
- `token::zero` - create an empty (zero balance) Token
- `token::destroy_zero` - destroy a Token with zero balance

### Protected

- `token::transfer` - transfer a Token to a specified address
- `token::to_coin` - convert a Token to a Coin
- `token::from_coin` - convert a Coin to a Token
- `token::spend` - spend a Token on a specified address

### Action Request

Protected actions generate an `ActionRequest` which need to be confirmed. 

```move
    public struct ActionRequest<phantom T> {
        /// Name of the Action to look up in the Policy. Name can be one of the
        /// default actions: `transfer`, `spend`, `to_coin`, `from_coin` or a
        /// custom action.
        name: String,
        /// Amount is present in all of the txs
        amount: u64,
        /// Sender is a permanent field always
        sender: address,
        /// Recipient is only available in `transfer` action.
        recipient: Option<address>,
        /// The balance to be "spent" in the `TokenPolicy`, only available
        /// in the `spend` action.
        spent_balance: Option<Balance<T>>,
        /// Collected approvals (stamps) from completed `Rules`. They're matched
        /// against `TokenPolicy.rules` to determine if the request can be
        /// confirmed.
        approvals: VecSet<TypeName>,
    }
```
## Confirming Action Requests

There are three ways to confirm an action request. 

- By `TreasuryCap`
- By `TokenPolicyCap`
- Through a defined token policy

## Setting Up Token Policy

- Create a Coin through `coin::create_currency`
- Create a policy for the respective token through `token::new_policy`
- Share the `TokenPolicy` Object 
- Create the respective rules for any or all action types
- Register, modify, or remove the rules from `TokenPolicy`

### Hierarchy

`Coin/Token Type` -> `TokenPolicy` -> `Rules`

## Parity Token Example

This is a simple closed loop token example illustrating how token policy can be defined and used.

The example allows minting in odd parity amounts of the token only. 

### Defining and Adding Token Policy

The specific token policy is defined in [parity_rule.move](../example_projects/closed_loop_token/sources/parity_rule.move).

Then this rule is added to the defined `PARITY` token in the `init` function of the [parity.move](../example_projects/closed_loop_token/sources/parity.move) contract.

### Full Contract

The full Parity Token example project is provided here: [Parity Token](../example_projects/closed_loop_token/)
