# Hot Potato Pattern

A hot potato is a struct that has no capabilities, therefore you can only pack and unpack it in its module. The Hot Potato Pattern leverages the PTB mechanics and is commonly used in cases when the application wants to enforce users to fulfill determined business logic before the transaction ends. In simpler terms, if a hot potato value is returned by the transaction command A, you must consume it in any subsequent command B within the same PTB. The most popular use case of Hot Potato Pattern is flashloan.

## Type Definitions

```move
module flashloan::flashloan {
    // === Imports ===
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::object::{UID};
    use sui::tx_context::{TxContext};

    /// For when the loan amount exceed the pool amount
    const ELoanAmountExceedPool: u64 = 0;
    /// For when the repay amount do not match the initial loan amount
    const ERepayAmountInvalid: u64 = 1;

    /// A "shared" loan pool.
    /// For demonstration purpose, we assume the loan pool only allows SUI.
    public struct LoanPool has key {
        id: UID,
        amount: Balance<SUI>,
    }

    /// A loan position.
    /// This is a hot potato struct, it enforces the users
    /// to repay the loan in the end of the transaction or within the same PTB.
    public struct Loan {
        amount: u64,
    }
}
```

We have a `LoanPool` shared object acting as a money vault ready for users to borrow. For simplicity sake, this pool only accepts SUI. Next, we have `Loan` which is a hot potato struct, we will use it to enforce users to repay the loan before transaction ends. `Loan` only has 1 field `amount` which is the borrowed amount.

## Borrow

```move
/// Function allows users to borrow from the loan pool.
/// It returns the borrowed [`Coin<SUI>`] and the [`Loan`] position
/// enforcing users to fulfill before the PTB ends.
public fun borrow(pool: &mut LoanPool, amount: u64, ctx: &mut TxContext): (Coin<SUI>, Loan) {
    assert!(amount <= balance::value(&pool.amount), ELoanAmountExceedPool);

    (
        coin::from_balance(balance::split(&mut pool.amount, amount), ctx),
        Loan {
            amount
        }
    )
}
```

Users can borrow the money from the `LoanPool` by calling `borrow()`. Basically, it will return the `Coin<SUI>` the users can use as they like for subsequent function calls. A `Loan` hot potato value is also returned. As mentioned previously, the only way to consume the `Loan` is through unpacking it in the functions from the same module. This allows only the application itself has the right to decide how to consume the hot potato, not external parties.

## Repay

```move
/// Repay the loan
/// Users must execute this function to ensure the loan is repaid before the transaction ends.
public fun repay(pool: &mut LoanPool, loan: Loan, payment: Coin<SUI>) {
    let Loan { amount } = loan;
    assert!(coin::value(&payment) == amount, ERepayAmountInvalid);

    balance::join(&mut pool.amount, coin::into_balance(payment));
}
```

Users at some point must `repay()` the loan before the PTB ends. We consume the `Loan` by unpacking it, otherwise, you will receive compiler error if you use its fields with direct access `loan.amount` as `Loan` is non-`drop`. After unpacking, we simply use the loan amount to perform valid payment check and update the `LoanPool` accordingly.

## Example

Let's try to create an example with flashloan where we borrow some SUI amount, use it to mint a dummy NFT and sell it to repay the debt. We will learn how to use PTB with Sui CLI to execute this all in one transaction.

```move
/// A dummy NFT to represent the flashloan functionality
public struct NFT has key{
    id: UID,
    price: Balance<SUI>,
}

/// Mint NFT
    public fun mint_nft(payment: Coin<SUI>, ctx: &mut TxContext): NFT {
        NFT {
            id: object::new(ctx),
            price: coin::into_balance(payment),
        }
    }

/// Sell NFT
public fun sell_nft(nft: NFT, ctx: &mut TxContext): Coin<SUI> {
    let NFT {id, price} = nft;
    object::delete(id);
    coin::from_balance(price, ctx)
}
```

You should able to publish the smart contract using the previous guide. After the smart deployment, we should have the package ID and the shared `LoanPool` object. Let's export them so we can use it later.

```bash
export LOAN_PACKAGE_ID=<package id>
export LOAN_POOL_ID=<object id of the loan pool>
```

You need to deposit some SUI amount using `flashloan::deposit_pool` function. For demonstration purpose, we will deposit 10_000 MIST in the loan pool.

```bash
sui client ptb \
--split-coins gas "[10000]" \
--assign coin \
--move-call $LOAN_PACKAGE_ID::flashloan::deposit_pool @$LOAN_POOL_ID coin.0 \
--gas-budget 10000000
```

Now let's build a PTB that `borrow() -> mint_nft() -> sell_nft() -> repay()`.

```bash
sui client ptb \
--move-call $LOAN_PACKAGE_ID::flashloan::borrow @$LOAN_POOL_ID 10000 \
--assign borrow_res \
--move-call $LOAN_PACKAGE_ID::flashloan::mint_nft borrow_res.0 \
--assign nft \
--move-call $LOAN_PACKAGE_ID::flashloan::sell_nft nft \
--assign repay_coin \
--move-call $LOAN_PACKAGE_ID::flashloan::repay @$LOAN_POOL_ID borrow_res.1 repay_coin \
--gas-budget 10000000
```

*Quiz: What happen if you don't call `repay()` at the end of the PTB, please try it yourself*

*💡Note: You may want to check out [SuiVision](https://testnet.suivision.xyz/) or [SuiScan](https://suiscan.xyz/testnet/home) to inspect the PTB for more details*