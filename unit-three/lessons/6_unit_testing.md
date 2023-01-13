# Unit Testing

Sui supports the [Move Testing Framework](https://github.com/move-language/move/blob/main/language/documentation/book/src/unit-testing.md). Here we will create some unit tests for `Managed Coin` to show how to write unit tests and run them.

## Testing Environment

Sui Move test codes are just like any other Sui Move codes, but they have special annotations and functions to distinguish them from actual production envrionment and the testing environment.

Your first start with `#[test]` or `#[test_only]` annotation on top of testing function or module to mark them as testing environment. 

```rust
#[test_only]
module fungible_tokens::managed_tests {
  #[test]
  fun mint_burn() {
  }
}
```

We will put the unit tests for `Managed Coin` into a separate testing module called `managed_tests`. 

Each function inside this module can be seen as one unit test consisiting of a single or multiple transactions. We are only going to write one unit test called `mint_burn` here. 

## Test Scenario

Inside the testing environment, we will be mainly leveraging the [`test_scenario` package](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/test_scenario.move) to simulate a runtime envrionment. The main object we need to understand and interact with here is the `Scenario` object. A `Scenario` simulates a multi-transaction sequence, and it can be initialized with the sender address as following:

```rust
  // Initialize a mock sender address
  let addr1 = @0xA;
  // Begins a multi transaction scenario with addr1 as the sender
  let scenario = test_scenario::begin(addr1);
  ...
  // Cleans up the scenario object
  test_scenario::end(scenario);  
```

*💡Note that the `Scenario` object is not droppable, so it must be explicitly cleaned up at the end of its scope using `test_scenario::end`.*

### Initializing the Module State

To test our `Managed Coin` module, we need to first initialize the module state. Given that our module has an `init` function, we need to first create a `test_only` init function inside the `managed` module:

```rust
#[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(MANAGED {}, ctx)
    }
```

This is essentially a mock `init` function that can only be used for testing. Then we can initialize the runtime state in our scenario by simply calling this function:

```rust
    // Run the managed coin module init function
    {
        managed::test_init(ctx(&mut scenario))
    };
```

### Minting 

We use the [`next_tx` method](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/test_scenario.move#L103) to advance to the next transaction in our scenario where we want to mint a `Coin<MANAGED>` object.

To do this, we need to first extract the `TreasuryCap<MANAGED>` object. We use a special testing function called `take_from_sender` to retrieve this from our scenario. Note that we need to pass into `take_from_sender` the type parameter of the object we are trying to retrieve. 

Then we simply call the `managed::mint` using all the necessary parameters. 

At the end of this transaction, we must return the `TreasuryCap<MANAGED>` object to the sender address using `test_scenario::return_to_address`.

```rust
next_tx(&mut scenario, addr1);
        {
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<MANAGED>>(&scenario);
            managed::mint(&mut treasurycap, 100, addr1, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<MANAGED>>(addr1, treasurycap);
        };
```

### Burning 

To testing burning a token, it's almost exactly the same as testing minting, except we also need to retrieve a `Coin<MANAGED>` object from the person it was minted to. 

## Running Unit Tests

The full [`managed_tests`](../example_projects/fungible_tokens/sources/managed_tests.move) module source code can be found under `example_projects` folder.

To run the unit tests, we simply need to type in the following command in CLI in the project directory:

```bash
  sui move test
```

You should see console output indicating which unit tests have passed or failed.

![Unit Test](../images/unittest.png)


