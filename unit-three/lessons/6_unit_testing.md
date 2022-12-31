# Unit Test

Sui supports the [Move Testing Framework](https://github.com/move-language/move/blob/main/language/documentation/book/src/unit-testing.md). Here we will give an example of how to right unit test codes and run your test code.

To run test, just need to type in the following command in CLI:

```bash
sui move test
```

Sui Move test codes are just like any other sui move codes, but they have special annotations and functions to distinguish them from actual production envrionment and the testing environment. 

```rust
#[test]
fun test_function() {
  use sui::test_scenario;
}
```

Your first start with `#[test]` annotation on top of testing function. Then inside the function, you will be mainly using `test_scenario` package to simulate runtime envrionment and transaction sequence.

Let's dive in using our previous `Transcript` examples. So now as a `SuperTeacher` yourself, you want to give teacher address `@0x1234` access to modify transcripts. Then you want to verify the works that is done by the teachers. The original code is in [here](../example_projects/transcript/sources/unittest.move)

```rust
#[test]
fun test_teacher() {
  use sui::test_scenario;
  let super_teacher = @0x1111;
  let teacher = @0x1234;
  let student = @0x4321;

  
  let scenario_val = test_scenario::begin(super_teacher);
  let scenario = &mut scenario_val;
  {
    	init(test_scenario::ctx(scenario));
  }
}
```

The above shows the scenario has been created, and passing the mutable reference of scenario into init function, which is equivalent to deploying the packages, triggering the constructor function of the smart contract. The init function we used here will create a `SuperTeacherCap` object and transfer it to the address `super_teacher`.

```rust
test_scenario::next_tx(scenario, super_teacher);
{
  let superTeacherCap = test_scenario::take_from_sender<SuperTeacherCap>(scenario);
	new_teacher(&superTeacherCap, teacher);
  test_scenario::return_to_sender(superTeacherCap);
}
```

The second transcaction is also called by `super_teacher` address. First will extract the `SuperTeacherCap` object out from the `super_teacher` address, who is also the transaction sender, therefore using `take_from_sender` will do the job. Then pass its reference to the `new_teacher` function to give `teacher` address a `TeacherCap` Object for further access in restricted functions. At last, after done using `superTeacherCap`, need to return it back to its owner, which is the sender `super_teacher`. 

```rust
test_scenario::next_tx(scenario, teacher);
{
  let teacherCap = test_scenario::take_from_sender<TeacherCap>(scenario);
  create(&teacherCap, 98, 99, 100, test_scenario::ctx(scenario));
  test_scenario::return_to_sender(scenario, teacherCap);
}
```

Now the third transaction will be done to let this new teacher to create a transcript with intended scores. Where history is 98, math is 99, literature is 100.

```rust
test_scenario::next_tx(scenario, teacher);
{
  let transcript = test_scenario::take_from_sender<Transcript>(scenario);
  assert!(get_math(&transcript) == 99);
  test_scenario::return_to_sender(scenario, transcript);
};
```

Then fourth transaction we will be checking if the score in the transcript is correct or not.

```rust
test_scenario::end(scenario_val);
```

Last we will close this test scenario.

To understand further on how to do unit test on sui move, check out [*HERE*](https://github.com/MystenLabs/sui/tree/7424aba44aece90f2969171629773bdc6c79ed7e/sui_programmability/examples) where they have test codes in every move files.

That's the end of Unit 2, thank you all!