// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module flashloan::flashloan {
    // === Imports ===
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::object::{UID};
    use sui::tx_context::{TxContext};

    // === Errors ===

    /// For when the loan amount exceed the pool amount
    const ELoanAmountExceedPool: u64 = 0;
    /// For when the repay amount do not match the initial loan amount
    const ERepayAmountInvalid: u64 = 1;

    // === Structs ===

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

    // === Public-Mutative Functions ===

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

    /// Repay the loan
    /// Users must execute this function to ensure the loan is repaid before the transaction ends.
    public fun repay(pool: &mut LoanPool, loan: Loan, payment: Coin<SUI>) {
        let Loan { amount } = loan;
        assert!(coin::value(&payment) == amount, ERepayAmountInvalid);

        balance::join(&mut pool.amount, coin::into_balance(payment));
    }
}