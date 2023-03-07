import { BCS, getSuiMoveConfig } from "@mysten/bcs";

// initialize the serializer with default Sui Move configurations
const bcs = new BCS(getSuiMoveConfig());

// Define some test data types
const integer = 10;
const array = [1, 2, 3, 4];
const string = "test string"

// use bcs.ser() to serialize data
const ser_integer = bcs.ser(BCS.U16, integer);
const ser_array = bcs.ser("vector<u8>", array);
const ser_string = bcs.ser(BCS.STRING, string);

// use bcs.de() to deserialize data
const de_integer = bcs.de(BCS.U16, ser_integer.toBytes());
const de_array = bcs.de("vector<u8>", ser_array.toBytes());
const de_string = bcs.de(BCS.STRING, ser_string.toBytes());

// Check results match up
console.assert(de_array.toString() === array.toString());
console.assert(de_integer.toString() === integer.toString());
console.assert(de_string.toString() === string.toString());
console.log(ser_integer.toString("hex"));
console.log(de_integer.toString());
console.log(ser_array.toString("hex"));
console.log(de_array.toString());
console.log(ser_string.toString("hex"));
console.log(de_string.toString());
