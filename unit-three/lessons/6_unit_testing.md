# Unit Testing

Sui supports the [Move Testing Framework](https://github.com/move-language/move/blob/main/language/documentation/book/src/unit-testing.md). Here we will create some unit tests for `Managed Coin` to show how to write unit tests and run them.

## Testing Environment

Sui Move test codes are just like any other Sui Move codes, but they have special annotations and functions to distinguish them from actual production envrionment and the testing environment.

Your first start with `#[test]` or `#[test_only]` annotation on top of testing function or module to mark them as testing environment. 

```rust
#[test]
fun test_function() {
  use sui::test_scenario;
}
```

```rust
#[test_only]
module fungible_tokens::managed_tests {

}
```

We will put the unit tests for `Managed Coin` into a separate testing module called `managed_tests`. 

## Test Scenario

Inside the testing environment, we will be mainly leveraging the `test_scenario` package to simulate runtime envrionment and a multi-transaction sequence. 

## Initializing the State

Let's look at what we need to do to test our 

```rust
    public fun test_init(ctx: &mut TxContext) {
        init(MANAGED {}, ctx)
    }
```

## Minting 

## Burning 

## Running Unit Tests

To run unit tests, we simply need to type in the following command in CLI in the project directory:

```bash
sui move test
```

