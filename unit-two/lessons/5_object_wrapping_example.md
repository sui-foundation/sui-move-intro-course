# Object Wrapping Example

We will implement an example of object wrapping to our transcript example, so that `WrappableTranscript` is wrapped by a `Folder` object, and so that `Folder` object can only be unpacked by, and thus the transcript inside only accessible by an intended address/viewer. 

## Modify `WrappableTranscript` and `Folder`

First, we need to make some adjustment to our two custom types `WrappableTranscript` and `Folder` from the previous section

1. We to add the `key` ability to our type definitions for `WrappableTranscript`, so that they become assets and are transferrable. 

Remember that custom types with the abilities `key` and `store` are considered to be assets in Sui Move. 

```rust
struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
}
```

2. We need to add an additional field `intended_address` to the `Folder` struct that indicates the address of the intended viewer of the wrapped transcript. 

``` rust
struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
    intended_address: address
}
```

## Request Transcript

```rust
public entry fun request_transcript(transcript: WrappableTranscript, intended_address: address, ctx: &mut TxContext){
    let folderObject = Folder {
        id: object::new(ctx),
        transcript,
        intended_address
    };
    transfer::transfer(folderObject, tx_context::sender(ctx))
}
```

This method simply takes in a `WrappableTranscript` object and wraps it in a `Folder` object, and transfers this object to the method caller. 

## Unwrap Transcript

```rust
public entry fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext){
    // Check that the person unpacking the transcript is the intended viewer
    assert!(folder.intended_address == tx_context::sender(ctx), 0);
    let Folder {
        id,
        transcript,
        intended_address:_,
    } = folder;
    transfer::transfer(transcript, tx_context::sender(ctx));
    // Deletes the wrapper Folder object
    object::delete(id)
    }
```

This method unwraps the `WrappableTranscript` object from the `Folder` wrapper object, and sends it to the method caller. 

There are a few new features of Sui Move that we haven't introduced before. Let's look at them one by one. 

### Assert



### Custom Errors



*Question: Why do we need to delete the wrapper object here manually? What happens if we don't delete it?*

## Full Example

The full sample code of what we have written so far can be found under [transcript_wrapped.move]().

