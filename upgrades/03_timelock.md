# Time-locked Upgrades
In some scenarios, the pre-set upgrade configurations supported in Leo may not be sufficient for a specific use case.
In these cases, developers can implement their own upgrade logic using the `"custom"` configuration.

**Note. Constructors are immutable and custom constructors can be tricky to get right. Extra care must be taken to ensure that logic is secure.**


## Initializing the Project
You may either use the existing `timelock` project
```
> cd timelock
```
or create a new Leo project with the following command:
```
> leo new timelock
```

## The Program

Now let's define the program that will be time-locked.

First query the network for the current block height.
```
> leo query block --latest-height
Leo ✅ Successfully retrieved data from 'http://localhost:3030/testnet/block/height/latest'.

1221
````

Now let's define the program.
```leo
program timelock_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}

    @custom
    async constructor() {
        if self.edition > 0u16 {
            assert(block.height >= 1300u32);
        }
    }
}
```

Note. The block height can be set to any value. `1300u32` is used for demonstration purposes.
For any upgrade, where the edition is greater than zero, then the constructor checks that the block height is greater than or equal to `1300u32`.
The constructor is called every time the program is deployed or upgraded.

## Deploying the Program

```
> leo deploy --broadcast
       Leo     11 statements before dead code elimination.
       Leo     11 statements after dead code elimination.
       Leo     The program checksum is: '[94u8, 103u8, 218u8, 226u8, 4u8, 153u8, 164u8, 219u8, 239u8, 17u8, 184u8, 136u8, 84u8, 196u8, 115u8, 62u8, 190u8, 58u8, 46u8, 249u8, 38u8, 92u8, 182u8, 68u8, 220u8, 45u8, 193u8, 97u8, 53u8, 226u8, 73u8, 1u8]'.
       Leo ✅ Compiled 'timelock_example.aleo' into Aleo instructions.
Attempting to determine the consensus version from the latest block height at http://localhost:3030...

🛠️  Deployment Plan Summary
──────────────────────────────────────────────
🔧 Configuration:
  Private Key:        APrivateKey1zkp8CZNn3yeC...
  Address:            aleo1rhgdu77hgyqd3xjj8uc...
  Endpoint:           http://localhost:3030
  Network:            testnet
  Consensus Version:  9

📦 Deployment Tasks:
  • timelock_example.aleo  │ priority fee: 0  │ fee record: no (public fee)

⚙️ Actions:
  • Transaction(s) will NOT be printed to the console.
  • Transaction(s) will NOT be saved to a file.
  • Transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with deployment? · yes


🔧 You program 'timelock_example.aleo' has the following constructor.
──────────────────────────────────────────────
constructor:
gt edition 0u16 into r0;
branch.eq r0 false to end_then_0_0;
gte block.height 1300u32 into r1;
assert.eq r1 true;
branch.eq true true to end_otherwise_0_1;
position end_then_0_0;
position end_otherwise_0_1;
──────────────────────────────────────────────
Once it is deployed, it CANNOT be changed.

✔ Would you like to proceed? · yes

📦 Creating deployment transaction for 'timelock_example.aleo'...


📊 Deployment Summary for timelock_example.aleo
──────────────────────────────────────────────
  Total Variables:      17,235
  Total Constraints:    12,927
  Max Variables:        2,097,152
  Max Constraints:      2,097,152

💰 Cost Breakdown (credits)
  Transaction Storage:  0.991000
  Program Synthesis:    0.754050
  Namespace:            1.000000
  Constructor:          0.270000
  Priority Fee:         0.000000
  Total Fee:            3.015050
──────────────────────────────────────────────

📡 Broadcasting deployment for timelock_example.aleo...
💰Your current public balance is 93749957.424097 credits.

✔ This transaction will cost you 3.01505 credits. Do you want to proceed? · yes

✉️ Broadcasted transaction with:
  - transaction ID: 'at17hj4p7s52mqgn432dwxxq09wryec6n6lza6lz57e93xm7s7fu5qqh7x4hh'
  - fee ID: 'au1evdsjegxaxtyrt86sfje43a7klyx09gcdu9qzuugq6nzwz44zgzsh8zswk'
🔄 Searching up to 12 blocks to confirm transaction (this may take several seconds)...
Explored 1 blocks.
Transaction accepted.
✅ Deployment confirmed!
```

If we query the network, we can see that the deployment transaction has been accepted.
```
> leo query transaction at17hj4p7s52mqgn432dwxxq09wryec6n6lza6lz57e93xm7s7fu5qqh7x4hh
```

After the block height bound is reached, the program can be optionally modified and upgraded.
You can verify this by first modifying the program, running `leo upgrade --broadcast`, and then.
```
> leo query program timelock_example.aleo
       Leo ✅ Successfully retrieved data from 'http://localhost:3030/testnet/program/timelock_example.aleo'.

program timelock_example.aleo;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

function foo: 

constructor:
    gt edition 0u16 into r0;
    branch.eq r0 false to end_then_0_0;
    gte block.height 1300u32 into r1;
    assert.eq r1 true;
    branch.eq true true to end_otherwise_0_1;
    position end_then_0_0;
    position end_otherwise_0_1;
```



