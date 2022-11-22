# Functions

In this section, we will introduce functions in Sui Move, and write our first Sui Move function as a part of our Hello World example. 

## Function Visibility

Sui Move functions have three types of visibility:

- **private**: the default visibility of a function; it can only be accessed by functions inside the same module
- **public**: the function is accessible by functions inside the same module, and by functions defined in another module
- **public(friend)**: the function is accessible by functions inside the same module and by functions defined in modules that are included on [the friends list](https://diem.github.io/move/friends.html){target=blank}

By default, Sui Move functions have private visibility. 

## Entry Functions

In Sui Move, entry functions are simply functions that can be called by a transactions. They are denoted by the keyword `entry`. 

### Transaction Context

Entry functions typically have the transaction context as the last parameter. This is a special parameter set by the Sui Move VM, and does not need to be specified by the user calling the function. 

The TxContext object contains essentially information about the transaction used to call the entry function, such as the sender's address, 

## Create the Function Code

### Hello World Object Struct Sample Code



