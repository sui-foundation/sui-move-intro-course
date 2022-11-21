# Hello World

## Initializing the Package

(If you skipped the previous section) You can initialize a Hello World Sui package with the following command:

`sui move new hello_world`

## Create the Contract Source File

Use an editor to create a Move contract source file called `hello.move` under the `sources` subfolder. 

And create the empty module as following:

    ```
        module hello_world::hello {

            // module contents

        }
    ```

## Define a Custom Type

A structure in Sui Move is a custom type which contains key-value pairs, where the key is a name of property and value is what's stored. Defined using keyword `struct`, a structure can have up to 4 abilities.

## Abilities

Abilities are keywords in Sui Move that 