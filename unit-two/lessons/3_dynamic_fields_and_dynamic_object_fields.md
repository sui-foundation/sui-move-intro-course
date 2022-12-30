## Dynamic Fields & Dynamic Object Fields

These might be new terminology for a lot of people so lets first get to what are `fields` and `object fields` first.

- **Fields** can store any value that has `store`, however an object stored in this kind of field will be considered wrapped and will not be accessible via its ID by external tools (explorers, wallets, etc) accessing storage.
- **Object field** values *must* be objects (have the `key` ability, and `id: UID` as the first field), but will still be accessible at their ID to external tools.

Here's the API to use for adding **dynamic field**:

```rust
public fun add<Name: copy + drop + store, Value: store>(
  object: &mut UID,
  name: Name,
  value: Value,
);
```

Here's the API to use for adding **dynamic object field**:

```rust
public fun add<Name: copy + drop + store, Value: key + store>(
  object: &mut UID,
  name: Name,
  value: Value,
);
```

As you can see, the difference between the two api access is by Value, whether the value is and object field or fields.

### Adding a child object

Here's an example of adding the `transcript`object as a dynamic object field of a `folder` object, this can be understood as the `transcript` object is owned by `folder` object as child object.

```rust
use sui::dynamic_object_field as ofield;
use sui::object::{UID};

// Now you want to have your transcript inside an envelope for storing. Let's forst define an envelope object
struct Envelope has key {
  id: UID
}

public entry fun add_transcript(envelope: &mut Envelope, transcript: TranscriptObject) {
	ofield::add(&mut envelope.id, b"transcript", transcript);
}
```

### Accessing/Modifying a child object

Now let's say you want to update a score in your transcript, then you can use `borrow` and `borrow_mut` to access and even modify them. Here's how:

```rust
module sui::dynamic_field {
  public fun borrow<Name: copy + drop + store, Value: store>(
      object: &UID,
      name: Name,
  ): &Value;
  public fun borrow_mut<Name: copy + drop + store, Value: store>(
      object: &mut UID,
      name: Name,
  ): &mut Value;
}
```

```rust
// If you just want to get a score
public entry fun get_english_score(envelope: &Envelope): u8 {
	let transcript = ofield::borrow<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
  transcript.history
}

// If you wish to update your history score
public entry fun update_english_score(envelope: &Envelope, score: u8){
	let transcript = ofield::borrow_mut<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
  transcript.history = score;
}
```

### Removing a child object

```rust
module sui::dynamic_field {
  public fun remove<Name: copy + drop + store, Value: store>(
      object: &mut UID,
      name: Name,
  ): Value;
}
```

```rust
// If you wish to take out your transcript from the envelope.
public entry fun remove_transcript_from_envelope(envelope: &mut Envelope) {
    let Transcript { id, history: _, math: _, literature: _ } = ofield::remove<vector<u8>, Child>(
        &mut envelope.id,
        b"transcript",
    );
    // object::delete(id); // step is used if you want to delete the transcript instance.
}
```

