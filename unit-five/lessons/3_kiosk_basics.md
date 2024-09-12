# Sui Kiosk

Now we have learned the basics of **Programmable Transaction Block** and **Hot Potato Design Pattern**, it is much easier for us to understand the mechanism behind **Sui Kiosk**. Let's get started

## What is Sui Kiosk?

We're probably familiar to some sort of kiosks in real life. It can be a stall in a tourist shopping mall selling you merchantdise, apparels or any local souvenirs. It can be in a form of big screen displaying you digital images of the products you're interested in. They may all come with different forms and sizes but they have one common trait: _they sell something and display their wares openly for passersby to browse and engage with_

**Sui Kiosk** is the digital version of these types of kiosk but for digital assets and collectibles. Sui Kiosk is a _decentralized system for onchain commerce applications on Sui_. Practically, Kiosk is a part of the Sui framework, and it is native to the system and available to everyone out of the box.

## Why Sui Kiosk?

Sui Kiosk is created to answer these needs:

- Can we list an item on marketplace and continue using it?
- Is there a way to create a “safe” for collectibles?
- Can we build an onchain system with custom logic for transfer management?
- How to favor creators and guarantee royalties?
- Can we avoid centralization of traditional marketplaces?

## Main Components

Sui Kiosk consists these 2 main components:

- `Kiosk` + `KioskOwnerCap`: `Kiosk` is the safe that will store our assets and display them for selling, it is implemented as a shared object allowing interactions between multiple parties. Each `Kiosk` will have a corresponding Kiosk Owner whoever holding the `KioskOwnerCap`. The Kiosk Owner still have the _logical ownership_ over their assets even when they are _physically_ placed in the kiosk.

- `TransferPolicy` + `TransferPolicyCap`: `TransferPolicy` is a shared object defines the conditions in which the assets can be traded or sold. Each `TransferPolicy` consists a set of _rules_, with each rule specifies the requirements every trade must sastify. Rules can be enabled or disabled from the `TransferPolicy` by whoever owning the `TransferOwnerCap`. Greater example of `TransferPolicy`'s rule is the royalty fees guarantee.

## Sui Kiosk Users

Sui Kiosk use-cases is centered around these 3 types of users:

- Kiosk Owner (Seller/KO): One must own the `KioskOwnerCap` to become the Kiosk Owner. KO can:
  - Place their assets in kiosk.
  - Withdraw the assets in kiosk if they're not _locked_.
  - List assets for sale.
  - Withdraw profits from sales.
  - Borrow and mutate owned assets in kiosk.
- Buyer: Buyer can be anyone who's willing to purchase the listed items. The buyers must satisfy the `TransferPolicy` for the trade to be considered successful.
- Creator: Creator is a party that creates and controls the `TransferPolicy` for a single type. For example, authors of SuiFrens collectibles are the creators of `SuiFren<Capy>` type and act as creators in the Sui Kiosk system. Creators can:
  - Set any rules for trades.
  - Set multiple tracks of rules.
  - Enable or disable trades at any moment with a policy.
  - Enforce policies (eg royalties) on all trades.
  - All operations are affected immediately and globally.

## Asset States in Sui Kiosk

When you add an asset to your kiosk, it has one of the following states:

- `PLACED` - an item is placed inside the kiosk. The Kiosk Owner can withdraw it and use it directly, borrow it (mutably or immutably), or list an item for sale.
- `LOCKED` - an item is placed and locked in the kiosk. The Kiosk Owner can't withdraw a _locked_ item from kiosk, but you can borrow it mutably and list it for sale.
- `LISTED` - an item in the kiosk that is listed for sale. The Kiosk Owner can’t modify an item while listed, but you can borrow it immutably or delist it, which returns it to its previous state.

_💡Note: there is another state called `LISTED EXCLUSIVELY`, which is not covered in this unit and will be covered in the future in advanced section_
