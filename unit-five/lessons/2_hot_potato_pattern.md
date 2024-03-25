# Hot Potato Pattern

A hot potato is a struct that has no capabilities, therefore you can only pack and unpack it in its module. The Hot Potato Pattern leverages the PTB mechanics and is commonly used in cases when the application wants to enforce users to fulfill determined business logic before the transaction ends. In simpler terms, if a hot potato value is returned by the transaction command A, you must consume it in any subsequent command B within the same PTB. The most popular use case of Hot Potato Pattern is flashloan.

## Type Definitions

```rust
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
    struct LoanPool has key {
        id: UID,
        amount: Balance<SUI>,
    }

    /// A loan position.
    /// This is a hot potato struct, it enforces the users
    /// to repay the loan in the end of the transaction or within the same PTB.
    struct Loan {
        amount: u64,
    }
}
```

We have a `LoanPool` shared object acting as a money vault ready for users to borrow. For simplicity sake, this pool only accepts SUI. Next, we have `Loan` which is a hot potato struct, we will use it to enforce users to repay the loan before transaction ends. `Loan` only has 1 field `amount` which is the borrowed amount.

## Borrow

```rust
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

```rust
/// Repay the loan
/// Users must execute this function to ensure the loan is repaid before the transaction ends.
public fun repay(pool: &mut LoanPool, loan: Loan, payment: Coin<SUI>) {
    let Loan { amount } = loan;
    assert!(coin::value(&payment) == amount, ERepayAmountInvalid);

    balance::join(&mut pool.amount, coin::into_balance(payment));
}
```

Users at some point must `repay()` the loan before the PTB ends. We consume the `Loan` by unpacking it, otherwise, you will receive compiler error if you use its fields with direct access `loan.amount` as `Loan` is non-`drop`. After unpacking, we simply use the loan amount to perform valid payment check and update the `LoanPool` accordingly.

