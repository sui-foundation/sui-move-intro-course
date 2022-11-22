# Custome Types and Abilities

In this section, we will start creating our Hello World example contract step by step and explain fundamental concepts in Sui Move as they come up, such as custom types and abilities. 

## Initializing the Package

(If you skipped the previous section) You can initialize a Hello World Sui package with the following command in the command line after [installing Sui binaries](https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-one/lessons/1_set_up_environment.md#install-sui-binaries-locally):

`sui move new hello_world`

## Create the Contract Source File

Use an editor of your choice to create a Move smart contract source file called `hello.move` under the `sources` subfolder. 

And create the empty module as following:

    ```
        module hello_world::hello {

            // module contents

        }
    ```

## Custom Types

A structure in Sui Move is a custom type which contains key-value pairs, where the key is the name of a property and value is what's stored. Defined using keyword `struct`, a structure can have up to 4 abilities.

### Abilities

Abilities are keywords in Sui Move that define how types behave at the compiler level. 

Abilities are crucial to defining how object behave in Sui Move at the language level. Each unique combination of abilities in Sui Move is its own design pattern. We will study abitilies and how to use them in Sui Move throughout the course.

For now, just know that there are four abilities in Sui Move:

- **Copy**: value can be copied (or cloned by value)
- **Drop**: value can be dropped by the end of scope
- **Key**: value can be used as a key for global storage operations
- **Store**: value can be stored inside global storage

Custom types that have the abilities `Key` and `Store` are considered to be **assets** in Sui Move. Assets are stored in global storage and can be transferred between accounts.  

### Hello World Object Struct Sample Code

We define the object in our Hello World example as the following:

```
    /// An object that contains an arbitrary string
    struct HelloWorldObject has key, store {
        id: UID,
        /// A string contained in the object
        text: string::String
    }
```

UID here is a Sui Move system type (sui::object::UID) that defines the globally unique ID of an object. 


