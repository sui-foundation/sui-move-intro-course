// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::transcript; 

use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

struct Transcript {
    history: u8,
    math: u8,
    literature: u8,
}

struct TranscriptObject has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
}

#[allow(lint(self_transfer))]
public fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
    let transcriptObject = TranscriptObject {
        id: object::new(ctx),
        history,
        math,
        literature,
    };
    transfer::transfer(transcriptObject, tx_context::sender(ctx))
}

// You are allowed to retrieve the score but cannot modify it
public fun view_score(transcriptObject: &TranscriptObject): u8{
    transcriptObject.literature
}

// You are allowed to view and edit the score but not allowed to delete it
public fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
    transcriptObject.literature = score
}

// You are allowed to do anything with the score, including view, edit, delete the entire transcript itself.
public fun delete_transcript(transcriptObject: TranscriptObject){
    let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
}