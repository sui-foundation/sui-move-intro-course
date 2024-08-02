# Programmable Transaction Block (PTB)

Before we get into **Sui Kiosk**, it's necessary to learn about Programmable Transaction Block (PTB) and how it helps us to seamlessly fulfill Kiosk usage flow

## Introduction

Most of us, more or less, have run into the situation where we want to batch a number of smaller transactions in order into a larger unit and submit one single transaction execution to the blockchain. In traditional blockchain, it was not feasible, and we need workarounds to make this work, the common solutions are:

- Submit the transactions subsequently one by one. This way works fine, but the performance of your dApps is demoted significantly as you need to wait for one transaction to be finalized before you can use their outputs for the next transaction in line. Moreover, the gas fee will not be a pleasant for the end-users.
- Create a new smart contract and a wrapper function to execute other functions from the same or different smart contracts. This approach may speed up your application and consume less gas fee but in return, reduce the developer experience as every new business use case might need a new wrapper function.

That’s why we introduce Programmable Transaction Block (PTB).

## Features

PTB is a built-in feature and supported natively by Sui Network and Sui VM. On Sui, a transaction (block) by default is a Programmable Transaction Block (PTB). PTB is a powerful tool enhancing developers with scalalability and composability:

- Each PTB is composed of multiple individual commands chaining together in order. One command that we will use most of the time is `MoveCall`. For other commands, please refer to the [documentation here](https://docs.sui.io/concepts/transactions/prog-txn-blocks#executing-a-transaction-command).
- When the transaction is executed, the commands are executed in the order they are defined when building the PTB. The outputs of one transaction command can be used as inputs for any subsequent commands.
- Sui guarantees the atomicity of a PTB by applying the effects of all commands in the transaction (block) at the end of the transaction. If one command fails, the entire block fails and effects will not take place.
- Each PTB can hold up to 1024 unique operations. This allows cheaper gas fee and faster execution compared to executing 1024 individual transactions in other traditional blockchains.
- If the output returned by one command is non-`drop` value. It must be consumed by subsequent commands within the same PTB. Otherwise, the transaction (block) is considered to be failed.

_💡Note: Refer to [documentation here](https://docs.sui.io/concepts/transactions/prog-txn-blocks) for full details on PTB_

## Usage

There are several ways we can use to build and execute a PTB:

- We already learned how to use the CLI `sui client call` to execute a single smart contract function. Behind the scenes, it is implemented using PTB with single `MoveCall` command. To build a PTB with full functionality, please use the CLI `sui client ptb` and refer to its [usage here](https://docs.sui.io/references/cli/ptb).
- Use the Sui SDK: [Sui Typescript SDK](https://sdk.mystenlabs.com/typescript), [Sui Rust SDK](https://docs.sui.io/references/rust-sdk).
