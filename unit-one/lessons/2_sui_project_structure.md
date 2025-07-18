# Sui Project Structure

## Sui Module and Package

- A Sui module is a set of functions and types packed together which the developer publishes under a specific address

- The Sui standard library is published under the `0x2` address, while user-deployed modules are published under a pseudorandom address assigned by the Sui Move VM

- Module starts with the `module` keyword, which is followed by the module name and curly braces - inside them, module contents are placed:

  ```move
  module hello_world::hello_world;
  // module contents
  ```

- Published modules are immutable objects in Sui; an immutable object is an object that can never be mutated, transferred, or deleted. Because of this immutability, the object is not owned by anyone, and hence it can be used by anyone

- A Move package is just a collection of modules with a manifest file called Move.toml

## Initializing a Sui Move Package

Use the following Sui CLI command to start a skeleton Sui package:

`sui move new <PACKAGE NAME>`

For our example in this unit, we will start a Hello World project:

`sui move new hello_world`

This creates:

- the project root folder `hello_world`
- the `Move.toml` manifest file with metadata about the package
- the `sources/` subfolder, which will contain Sui Move smart contract source files
- the `tests/` subfolder, which will containing tests for the package. Code placed into the tests directory is not published on-chain and is only available in tests

### `Move.toml` Manifest Structure

`Move.toml` is the manifest file of a package and is automatically generated in the project root folder.

`Move.toml` consists of several sections:

- `[package]` Describes the package with fields like name (used when package is imported), version (for release management), and edition (Move language edition, currently 2024)
- `[dependencies]` Specifies dependencies of the project. Each dependency can be a git repository or local directory path. Packages also import addresses from dependencies
- `[dev-dependencies]` Used to override dependencies in the dev and test modes. For example, if you want to use a different version of the Sui package in the dev mode, you can add a custom dependency specification to the [dev-dependencies] section
- `[addresses]` Adds aliases for addresses that can be used in the code as shortcuts for full addresses
- `[dev-addresses]` Allows overriding existing address aliases for test and dev modes only. Cannot introduce new aliases, only override existing ones

#### Sample `Move.toml` File

This is the `Move.toml` generated by the Sui CLI with the package name `hello_world`:

```toml
[package]
name = "hello_world"
edition = "2024.beta" # edition = "legacy" to use legacy (pre-2024) Move
# license = ""           # e.g., "MIT", "GPL", "Apache 2.0"
# authors = ["..."]      # e.g., ["Joe Smith (joesmith@noemail.com)", "John Snow (johnsnow@noemail.com)"]

[dependencies]
# For remote import, use the `{ git = "...", subdir = "...", rev = "..." }`.
# Revision can be a branch, a tag, and a commit hash.
# MyRemotePackage = { git = "https://some.remote/host.git", subdir = "remote/path", rev = "main" }

# For local dependencies use `local = path`. Path is relative to the package root
# Local = { local = "../path/to" }

# To resolve a version conflict and force a specific version for dependency
# override use `override = true`
# Override = { local = "../conflicting/version", override = true }

[addresses]
hello_world = "0x0"

# Named addresses will be accessible in Move as `@name`. They're also exported:
# for example, `std = "0x1"` is exported by the Standard Library.
# alice = "0xA11CE"

[dev-dependencies]
# The dev-dependencies section allows overriding dependencies for `--test` and
# `--dev` modes. You can introduce test-only dependencies here.
# Local = { local = "../path/to/dev-build" }

[dev-addresses]
# The dev-addresses section allows overwriting named addresses for the `--test`
# and `--dev` modes.
# alice = "0xB0B"
```

## Dependencies

The `[dependencies]` section is used to specify the dependencies of the project. Each dependency is specified as a key-value pair, where the key is the name of the dependency, and the value is the dependency specification. The dependency specification can be a git repository URL or a path to the local directory.

```toml
# git repository
Example = { git = "https://github.com/example/example.git", subdir = "path/to/package", rev = "framework/testnet" }

# local directory
MyPackage = { local = "../my-package" }
```

Packages also import addresses from other packages. For example, the Sui dependency adds the `std` and `sui` addresses to the project. These addresses can be used in the code as aliases for the addresses.

Starting with version 1.45 of the Sui CLI, the Sui system packages (`std`, `sui`, `system`, `bridge`, and `deepbook`) are automatically added as dependencies if none of them are explicitly listed.

### Resolving Version Conflicts with Override

Sometimes dependencies have conflicting versions of the same package. For example, if you have two dependencies that use different versions of the Example package, you can override the dependency in the `[dependencies]` section. To do so, add the `override` field to the dependency. The version of the dependency specified in the `[dependencies]` section will be used instead of the one specified in the dependency itself.

```toml
[dependencies]
Example = { override = true, git = "https://github.com/example/example.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
```

## Sui Module and Package Naming

- Sui Move module and package naming convention use snake casing, i.e. this_is_snake_casing.

- A Sui module name uses the Rust path separator `::` to divide the package name and the module name, examples:

  1. `unit_one::hello_world` - `hello_world` module in `unit_one` package
  2. `capy::capy` - `capy` module in `capy` package

- For more information on Move naming conventions, please check [the style section](https://move-language.github.io/move/coding-conventions.html#naming) of the Move book.
