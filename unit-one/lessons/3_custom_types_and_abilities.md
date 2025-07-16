# Custom Types and Abilities

In this section, we will start creating our Hello World example contract step by step and explain fundamental concepts in Sui Move as they come up, such as custom types and abilities.

## Initializing the Package

(If you skipped the previous section) You can initialize a Hello World Sui package with the following command in the command line after [installing Sui binaries](./1_set_up_environment.md#install-sui-binaries-locally):

`sui move new hello_world`

## Create the Contract Source File

Use an editor of your choice to create a Move smart contract source file called `hello.move` under the `sources` subfolder.

And create the empty module as follows:

```move
module hello_world::hello_world;
// module contents
```

### Import Statements

You can directly import modules in Move by their address, but to make code easier to read, we can organize imports with the keyword `use`.

```move
use <Address/Alias>::<ModuleName>;
```

In our example, we need to import the following modules:

```move
use std::string;
```

### Implicit Imports

Some modules are imported implicitly and are available in the module without the explicit `use` import. For the Standard Library, these modules and types include:

- `std::vector`
- `std::option`
- `std::option::Option`

Just like with Standard Library, some of the modules and types are imported implicitly in the Sui Framework. This is the list of modules and types that are available without explicit `use` import:

- `sui::object`
- `sui::object::ID`
- `sui::object::UID`
- `sui::tx_context`
- `sui::tx_context::TxContext`
- `sui::transfer`

### Method Call Syntax

Move supports method call syntax using the `.` operator as a syntactic convenience. The value on the left-hand side of the `.` becomes the first argument to the function. All method calls are statically determined at compile time.

```move
// Traditional function call syntax
let sender = tx_context::sender(ctx);
let text = string::utf8(b"Hello World!");

// Method call syntax
let sender = ctx.sender();
let text = b"Hello World!".to_string();
```

Method call syntax works when the first parameter of a function matches the type before the dot. The compiler automatically creates method aliases for functions in the defining module and will automatically borrow the receiver if needed.

## Custom Types

A structure in Sui Move is a custom type that contains key-value pairs, where the key is the name of a property, and the value is what's stored. Defined using the keyword `struct`, a structure can have up to 4 abilities.

### Abilities

Abilities are keywords in Sui Move that define how types behave at the compiler level.

Abilities are crucial to defining how objects behave in Sui Move at the language level. Each unique combination of abilities in Sui Move is its own design pattern. We will study abilities and how to use them in Sui Move throughout the course.

For now, just know that there are four abilities in Sui Move:

- **copy**: value can be copied (or cloned by value)
- **drop**: value can be dropped by the end of the scope
- **key**: value can be used as a key for global storage operations
- **store**: value can be held inside a struct in global storage

#### Assets

Custom types that have the abilities `key` and `store` are considered to be **assets** in Sui Move. Assets are stored in global storage and can be transferred between accounts.

### Hello World Custom Type

We define the object in our Hello World example as the following:

```move
/// An object that contains an arbitrary string
public struct HelloWorldObject has key, store {
  	id: UID,
  	/// A string contained in the object
  	text: string::String
}
```

UID here is a Sui Framework type (sui::object::UID) that defines the globally unique ID of an object. Any custom type with the `key` ability is required to have an ID field.
