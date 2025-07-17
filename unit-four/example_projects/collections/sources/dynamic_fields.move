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

// Adds a DFChild to the parent object under the provided name
public fun add_dfchild(parent: &mut Parent, child: DFChild, name: vector<u8>) {
    df::add(&mut parent.id, name, child);
}

// Adds a DOFChild to the parent object under the provided name
public fun add_dofchild(
    parent: &mut Parent,
    child: DOFChild,
    name: vector<u8>,
) {
    dof::add(&mut parent.id, name, child);
}

// Borrows a reference to a DOFChild
public fun borrow_dofchild(child: &DOFChild): &DOFChild {
    child
}

// Borrows a reference to a DFChild via its parent object
public fun borrow_dfchild_via_parent(
    parent: &Parent,
    child_name: vector<u8>,
): &DFChild {
    df::borrow<vector<u8>, DFChild>(&parent.id, child_name)
}

// Borrows a reference to a DOFChild via its parent object
public fun borrow_dofchild_via_parent(
    parent: &Parent,
    child_name: vector<u8>,
): &DOFChild {
    dof::borrow<vector<u8>, DOFChild>(&parent.id, child_name)
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
    child_name: vector<u8>,
) {
    let child = df::borrow_mut<vector<u8>, DFChild>(
        &mut parent.id,
        child_name,
    );
    child.count = child.count + 1;
}

// Mutate a DOFChild's counter via its parent object
public fun mutate_dofchild_via_parent(
    parent: &mut Parent,
    child_name: vector<u8>,
) {
    mutate_dofchild(
        dof::borrow_mut<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        ),
    );
}

// Removes a DFChild given its name and parent object's mutable reference, and
// returns it by value
public fun remove_dfchild(
    parent: &mut Parent,
    child_name: vector<u8>,
): DFChild {
    df::remove<vector<u8>, DFChild>(&mut parent.id, child_name)
}

// Removes a DOFChild given its name and parent object's mutable reference, and
// returns it by value
public fun remove_dofchild(
    parent: &mut Parent,
    child_name: vector<u8>,
): DOFChild {
    dof::remove<vector<u8>, DOFChild>(&mut parent.id, child_name)
}

// Deletes a DOFChild given its name and parent object's mutable reference
public fun delete_dofchild(parent: &mut Parent, child_name: vector<u8>) {
    let DOFChild { id, .. } = remove_dofchild(parent, child_name);
    id.delete();
}

#[lint_allow(self_transfer)]
// Removes a DOFChild from the parent object and transfer it to the caller
public fun reclaim_dofchild(
    parent: &mut Parent,
    child_name: vector<u8>,
    ctx: &mut TxContext,
) {
    let child = remove_dofchild(parent, child_name);
    transfer::public_transfer(child, ctx.sender());
}
