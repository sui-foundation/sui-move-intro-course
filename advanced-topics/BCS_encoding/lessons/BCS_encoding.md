# BCS Encoding

Binary Canonical Serialization, or BCS, is a serialization format developed in the context of the Diem blockchain and is now extensively used in most of the blockchains based on Move (Sui, Starcoin, Aptos, 0L). BCS is not only used in the Move VM, but also used in transaction and event coding, such as serializing transactions before signing, or parsing event data.

Knowing how BCS works is crucial if you want to understand how Move works at a deeper level and become a Move expert. Let's dive in.

## BCS Specification and Properties

There are some high-level properties of BCS encoding that are good to keep in mind as we go through the rest of the lesson:

- BCS is a data-serialization format where the resulting output bytes do not contain any type information; because of this, the side receiving the encoded bytes will need to know how to deserialize the data
- There are no structs in BCS (since there are no types); the struct simply defines the order in which fields are serialized
- Wrapper types are ignored, so `OuterType` and `UnnestedType` will have the same BCS representation:

  ```move
  public struct OuterType {
      owner: InnerType
  }
  public struct InnerType {
      address: address
  }
  public struct UnnestedType {
      address: address
  }
  ```

- Types containing the generic type fields can be parsed up to the first generic type field. So it's a good practice to put the generic type field(s) last if it's a custom type that will be ser/de'd.
  ```move
  public struct BCSObject<T> has drop, copy {
      id: ID,
      owner: address,
      meta: Metadata,
      generic: T
  }
  ```
  In this example, we can deserialize everything up to the `meta` field.
- Primitive types like unsigned ints are encoded in Little Endian format
- Vector is serialized as a [ULEB128](https://en.wikipedia.org/wiki/LEB128) length (with max length up to `u32`) followed by the content of the vector.

The full BCS specification can be found in [the BCS repository](https://github.com/zefchain/bcs).

## Using the `@mysten/bcs` JavaScript Library

### Installation

The library you will need to install for this part is the [@mysten/bcs library](https://www.npmjs.com/package/@mysten/bcs). You can install it by typing in the root directory of a node project:

```bash
npm i @mysten/bcs
```

### Basic Example

Let's use the JavaScript library to serialize and de-serialize some simple data types first:

```javascript
import { bcs } from "@mysten/bcs";

// Define some test data types
const integer = 10;
const array = [1, 2, 3, 4];
const string = "test string";

// use .serialize() to serialize data
const ser_integer = bcs.u16().serialize(integer);
const ser_array = bcs.vector(bcs.u8()).serialize(array);
const ser_string = bcs.string().serialize(string);

// use .parse() to deserialize data
const de_integer = bcs.u16().parse(ser_integer.toBytes());
const de_array = bcs.vector(bcs.u8()).parse(ser_array.toBytes());
const de_string = bcs.string().parse(ser_string.toBytes());
```

The serializer can be imported directly from the `@mysten/bcs` library using the above syntax.

There are built-in methods that can be used for Sui Move types like `bcs.u16()`, `bcs.string()`, etc. For [generic types](../../../unit-three/lessons/2_intro_to_generics.md), you can use methods like `bcs.vector(bcs.u8())` for vectors.

Let's take a close look at the serialized and deserialized fields:

```bash
# ints are little-endian hexadecimals
0a00
10
# The first element of a vector indicates the total length,
# then it's just whatever elements are in the vector
0401020304
1,2,3,4
# strings are just vectors of u8's, with the first element equal to the length of the string
0b7465737420737472696e67
test string
```

### Type Registration

We can register the custom types we will be working with using the following syntax:

```javascript
import { bcs, fromHex, toHex } from "@mysten/bcs";

// Define Address as a 32-byte array, then add a transform to/from hex strings
const Address = bcs.fixedArray(32, bcs.u8()).transform({
  input: (id) => fromHex(id),
  output: (id) => toHex(Uint8Array.from(id)),
});

// Register the struct types
const bcsStruct = bcs.struct("BCSObject", {
  id: Address,
  owner: Address,
  meta: bcs.struct("Metadata", {
    name: bcs.string(),
  }),
});
```

## Using `bcs` in Sui Smart Contracts

Let's continue our example from above with the structs.

### Struct Definition

We start with the corresponding struct definitions in the Sui Move contract.

```move
public struct Metadata has copy, drop {
    name: ascii::String,
}

public struct BCSObject has copy, drop {
    id: ID,
    owner: address,
    meta: Metadata,
}
```

### Deserialization

Now, let's write the function to deserialize an object in a Sui contract.

```move
public fun object_from_bytes(bcs_bytes: vector<u8>): BCSObject {
    let mut bcs = bcs::new(bcs_bytes);

    // Use `peel_*` functions to peel values from the serialized bytes.
    // Order has to be the same as we used in serialization!
    let (address, owner, meta) = (
        bcs.peel_address(),
        bcs.peel_address(),
        bcs.peel_vec_u8(),
    );
    // Pack a BCSObject struct with the results of serialization
    BCSObject {
        id: address.to_id(),
        owner,
        meta: Metadata { name: meta.to_ascii_string() },
    }
}
```

The various `peel_*` methods in Sui Frame [`bcs` module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/bcs.md) are used to "peel" each individual field from the BCS serialized bytes. Note that the order we peel the fields must be exactly the same as the order of the fields in the struct definition.

_Quiz: Why are the results not the same from the first two `peel_address` calls on the same `bcs` object?_

Also note how we convert the types from `address` to `ID` using `to_id()`, and from `vector<u8>` to `ascii::String` using `to_ascii_string()`.

_Quiz: What would happen if `BCSObject` had a `UID` type instead of an `ID` type?_

## Complete Ser/De Example

Find the full JavaScript and Sui Move sample codes in the [`example_projects`](https://github.com/sui-foundation/sui-move-intro-course/tree/main/advanced-topics/BCS_encoding/example_projects) folder.

First, we serialize a test object using the JavaScript program:

```javascript
import { bcs, fromHex, toHex } from "@mysten/bcs";

// Define Address as a 32-byte array, then add a transform to/from hex strings
const Address = bcs.fixedArray(32, bcs.u8()).transform({
  input: (id) => fromHex(id),
  output: (id) => toHex(Uint8Array.from(id)),
});

// We construct a test object to serialize
const bcsStruct = bcs.struct("BCSObject", {
  id: Address,
  owner: Address,
  meta: bcs.struct("Metadata", {
    name: bcs.string(),
  }),
});

const serialized = bcsStruct.serialize({
  id: "0x0000000000000000000000000000000000000000000000000000000000000005",
  owner: "0x000000000000000000000000000000000000000000000000000000000000000A",
  meta: {
    name: "aaa",
  },
});

console.log("Hex:", serialized.toHex());
```

We can get the serialization result in hexadecimal format using the `toHex()` method.

Affix the serialization result hexstring with `0x` prefix and export to an environmental variable:

```bash
export OBJECT_HEXSTRING=0x0000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000a03616161
```

Now we can either run the associated Move unit tests to check for correctness:

```bash
sui move test
```

You should see this in the console:

```bash
BUILDING bcs_move
Running the Move unit tests
[ PASS    ] 0x0::bcs_object::test_deserialization
Test result: OK. Total tests: 1; passed: 1; failed: 0
```

Or we can publish the module (and export the PACKAGE_ID) and call the `emit_object` method using the above BCS serialized hexstring:

```bash
sui client call --function emit_object --module bcs_object --package $PACKAGE_ID --args $OBJECT_HEXSTRING
```

We can then check the `Events` tab of the transaction on the Sui Explorer to see that we emitted the correctly deserialized `BCSObject`:

![Event](../images/event.png)
