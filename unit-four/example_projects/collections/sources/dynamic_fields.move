// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module collection::dynamic_fields;

use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;

// Parent struct
public struct Parent has key {
    id: UID,
}

// Dynamic field child struct type containing a counter
public struct DFChild has store {
    count: u64,
}

// Dynamic object field child struct type containing a counter
public struct DOFChild has key, store {
    id: UID,
    count: u64,
}

// Key type for dynamic fields — positional struct (Move 2024)
#[allow(unused_field)]
public struct ChildNameKey(vector<u8>) has copy, drop, store;

// Adds a DFChild to the parent object under the provided key
public fun add_dfchild(parent: &mut Parent, child: DFChild, key: ChildNameKey) {
    df::add(&mut parent.id, key, child);
}

// Adds a DOFChild to the parent object under the provided key
public fun add_dofchild(
    parent: &mut Parent,
    child: DOFChild,
    key: ChildNameKey,
) {
    dof::add(&mut parent.id, key, child);
}

// Borrows a reference to a DOFChild
public fun borrow_dofchild(child: &DOFChild): &DOFChild {
    child
}

// Borrows a reference to a DFChild via its parent object
public fun borrow_dfchild_via_parent(
    parent: &Parent,
    key: ChildNameKey,
): &DFChild {
    df::borrow<ChildNameKey, DFChild>(&parent.id, key)
}

// Borrows a reference to a DOFChild via its parent object
public fun borrow_dofchild_via_parent(
    parent: &Parent,
    key: ChildNameKey,
): &DOFChild {
    dof::borrow<ChildNameKey, DOFChild>(&parent.id, key)
}

// Mutate a DOFChild directly
public fun mutate_dofchild(child: &mut DOFChild) {
    child.count = child.count + 1;
}

// Mutate a DFChild directly
public fun mutate_dfchild(child: &mut DFChild) {
    child.count = child.count + 1;
}

// Mutate a DFChild's counter via its parent object
public fun mutate_dfchild_via_parent(
    parent: &mut Parent,
    key: ChildNameKey,
) {
    let child = df::borrow_mut<ChildNameKey, DFChild>(&mut parent.id, key);
    child.count = child.count + 1;
}

// Mutate a DOFChild's counter via its parent object
public fun mutate_dofchild_via_parent(
    parent: &mut Parent,
    key: ChildNameKey,
) {
    mutate_dofchild(dof::borrow_mut<ChildNameKey, DOFChild>(&mut parent.id, key));
}

// Removes a DFChild given the key and parent's mutable reference; returns it by value
public fun remove_dfchild(
    parent: &mut Parent,
    key: ChildNameKey,
): DFChild {
    df::remove<ChildNameKey, DFChild>(&mut parent.id, key)
}

// Removes a DOFChild given the key and parent's mutable reference; returns it by value
public fun remove_dofchild(
    parent: &mut Parent,
    key: ChildNameKey,
): DOFChild {
    dof::remove<ChildNameKey, DOFChild>(&mut parent.id, key)
}

// Deletes a DOFChild given the key and parent's mutable reference
public fun delete_dofchild(parent: &mut Parent, key: ChildNameKey) {
    let DOFChild { id, .. } = remove_dofchild(parent, key);
    id.delete();
}

#[lint_allow(self_transfer)]
// Removes a DOFChild from the parent and transfers it to the caller
public fun reclaim_dofchild(
    parent: &mut Parent,
    key: ChildNameKey,
    ctx: &mut TxContext,
) {
    let child = remove_dofchild(parent, key);
    transfer::public_transfer(child, ctx.sender());
}
