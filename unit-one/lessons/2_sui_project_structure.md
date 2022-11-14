# Sui Project Structure 

## Move Module

- A Move module is a set of functions and types packed together which the developer publishes under a specific address. 

- Sui standard library is generally published under the `0x2` address, while user deployed modules are published under a pseodorandom address assigned by the Sui Move VM. 

- Module starts with the `module` keyword, which is followed by module name and curly braces - inside them module contents are placed:

```
module HelloWorld {

    // module contents

}
```

- Published modules are immutable objects in Sui; An immutable object is an object that can never be mutated, transferred or deleted. Because of this immutability, the object is not owned by anyone, and hence it can be used by anyone.

## Move.toml File



## Module and Package Naming
