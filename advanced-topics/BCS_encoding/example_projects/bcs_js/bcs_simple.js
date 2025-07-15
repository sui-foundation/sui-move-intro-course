import { bcs } from "@mysten/bcs";

// Define some test data types
const integer = 10;
const array = [1, 2, 3, 4];
const string = "test string"

// use bcs.serialize() to serialize data
const ser_integer = bcs.u16().serialize(integer);
const ser_array = bcs.vector(bcs.u8()).serialize(array);
const ser_string = bcs.string().serialize(string);

// use bcs.parse() to deserialize data
const de_integer = bcs.u16().parse(ser_integer.toBytes());
const de_array = bcs.vector(bcs.u8()).parse(ser_array.toBytes());
const de_string = bcs.string().parse(ser_string.toBytes());

// Check results match up
console.assert(de_array.toString() === array.toString());
console.assert(de_integer.toString() === integer.toString());
console.assert(de_string.toString() === string.toString());
console.log(ser_integer.toHex());
console.log(de_integer.toString());
console.log(ser_array.toHex());
console.log(de_array.toString());
console.log(ser_string.toHex());
console.log(de_string.toString());
