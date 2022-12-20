# Events

Events are important for sui move smart contracts, as it is the main way to track actions on chain. You can understand it as logging on server backends.

To use events in Sui, you just need to `use sui::event`.

Here's an example of how to use event in Sui Move.

```rust
module sui_intro_unit_two::events {
	use sui::event;
  struct Transcript has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
  }
  
  // ....create transacript functions, init functions, etc, you can find them in Capability Design Pattern section.
  
  public entry fun print_transcript(transcript: &Transcript) {
		event::emit(transcript);
  }
}
```

Just need to pass in any objects, variables, then it shall be printed and waiting to be observed using Sui API. For tutorials on how to get event using API, check [*HERE*](https://docs.sui.io/devnet/build/event_api).

The updated version of capability design codes with events can be found in [*HERE*](../example_projects/transcript/sources/event.move)
