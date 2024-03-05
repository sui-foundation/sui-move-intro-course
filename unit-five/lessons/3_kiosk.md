# Sui Kiosk

Now we have learned the basics of **Programmable Transaction Block** and **Hot Potato Design Pattern**, it is much easier for us to understand the mechanism behind **Sui Kiosk**. Let's get started

## What is Sui Kiosk?

We're probably familiar to some sort of kiosks in real life. It can be a stall in a tourist shopping mall selling you merchantdise, apparels or any local souvenirs. It can be in a form of big screen displaying you digital images of the products you're interested in. They may all come with different forms and sizes but they have one common trait: *they sell something and display their wares openly for passersby to browse and engage with*

**Sui Kiosk** is the digital version of these types of kiosk but for digital assets and collectibles. Sui Kiosk is a *decentralized system for onchain commerce applications on Sui*. Practically, Kiosk is a part of the Sui framework, and it is native to the system and available to everyone out of the box.

## Why Sui Kiosk?

Sui Kiosk is created to answer these needs:
- Can we list an item on marketplace and continue using it?
- Is there a way to create a “safe” for collectibles?
- Can we build an onchain system with custom logic for transfer management?
- How to favor creators and guarantee royalties?
- Can we avoid centralization of traditional marketplaces?

## Main Components

Sui Kiosk consists these 2 main components:
- `Kiosk` + `KioskOwnerCap`: `Kiosk` is the safe that will store our assets and display them for selling, it is implemented as a shared object allowing interactions between multiple parties. Each `Kiosk` will have a corresponding Kiosk Owner whoever holding the `KioskOwnerCap`. The Kiosk Owner still have the *logical ownership* over their assets even when they are *physically* put into the kiosk.
- `TransferPolicy` + `TransferPolicyCap`: `TransferPolicy` defines the conditions in which the assets can be traded or sold. Each `TransferPolicy` consists a set of *rules*, with each rule specifies the requirements every trade must sastify. Rules can be enabled or disabled from the `TransferPolicy` by whoever owning the `TransferOwnerCap`. Greate example of `TransferPolicy`'s rule is the royalty fees guarantee.

## Asset States in Sui Kiosk

Sui Kiosk is a shared object that can store heterogeneous values, such as different sets of asset collectibles. When you add an asset to your kiosk, it has one of the following states:
- `PLACED` - an item is placed inside the Kiosk

## Sui Kiosk Users

Sui Kiosk serves these types of users. 

### Kiosk Owner (Seller/KO)

To become the Kiosk Owner, one must own the `KioskOwnerCap`. To create the Kiosk, we can use the 

