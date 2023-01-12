# Intro to Generics

Generics are abstract stand-ins for concrete types or other properties. They work similarly to [generics in Rust](https://doc.rust-lang.org/stable/book/ch10-00-generics.html), and can be used to allow greater flexibility and avoid logic duplication while writing Sui Move code.

Generics are a key concept in Sui Move, and it's important to understand and have an intuition for how they work, so take your time with this section and understand every part fully. 

## Generics Usage

### Using Generics in Structs

Let's look at a basic example of how to use generics to create a container `Box` that can hold any type in Sui Move.

First, without generics, we can define a `Box` that holds a `u64` type as the following:

```rust
module Storage {
    struct Box {
        value: u64
    }
}
```

However, this type will only be able to hold a value of type `u64`, to make our `Box` able to hold any generic type, we will need to use generics. The code would be modified as following:

```rust
module Storage {
    struct Box<T> {
        value: T
    }
}
```

#### Ability Constraints

We can add conditions to check that the type passed into the generic must have certain abilities. The syntax looks like the following:

```rust
module Storage {
    // T must be copyable and droppable 
    struct Box<T: copy + drop> has copy {
        value: T
    }
}
```

*💡Note: It's very important to note here that the inner type `T` in the above example must have the ability (or abilities) or the outer container type. In this example, `T` must be copyable, as `Box` is copyable. However, `T` can also have abilities that the container doesn't have, such as `drop` in this example.*

The intuition is that if the container is allowed to contain a type that does not follow the same rules that it does, the container would violate its own ability. How can a box be copyable if its content isn't also copyable?

We will see in the next section that there is a way to get around this rule in certain cases using a special keyword, called `phantom`. 

### Using Generics in Functions

To write a function that returns an instance of `Box` that can accept a parameter of any type for the `value` field, we also have to use generics in the function definition. The function can be defined as the following:

```rust
public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }
```

If we want to restrict the function to only accept a specific type for `value`, we simply specify that type in the function signature as follows:

```rust
public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
```

This will only accept inputs of the type `u64` for the `create_box` method, while still using the same generic `Box` struct. 

#### Calling Functions with Generics

To call a function with a signature that contains generics, we must specify the type in square brackets, as in the following syntax:

```rust
// value will be of type Storage::Box<bool>
    let bool_box = Storage::create_box<bool>(true);
// value will be of the type Storage::Box<u64>
    let u64_box = Storage::create_box<u64>(1000000);
```

#### Calling Functions with Generics using Sui CLI

To call a function with generics in its signature from the Sui CLI, you must define the argument's type using the flag `--type-args`.

The following is an example that calls the `create_box` function to create a box that contains a coin of the type `0x2::sui::SUI`:

```bash
sui client call --package $PACKAGE --module $MODULE --function "create_box" --args $OBJECT_ID --type-args 0x2::sui::SUI --gas-budget 10000
```

## Advanced Generics Syntax

For more advanced syntax involving the use of generics in Sui Move, such as multiple generic types, please refer to the excellent [section on generics in the Move Book](https://move-book.com/advanced-topics/understanding-generics.html). 

But for our current lesson on fungible tokens, you already know enough about how generics work to proceed. 




