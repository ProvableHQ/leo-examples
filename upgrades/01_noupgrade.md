# Non-upgradable Programs
In many cases, developers will want to deploy a program that is not upgradable.
This is the default mode supported by Leo.
Let's take a look at a simple example.

## Initializing the Project
You may either use the existing `noupgrade` project 
```
> cd noupgrade 
```
or create a new Leo project with the following command:
```
> leo new noupgrade
```

## The Program
```leo
program noupgrade_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
    
    @noupgrade
    async constructor() {}
}
```
Upgrades are defined by the logic of the `constructor`.
The constructor is an **immutable** asynchronous function that is strictly on-chain.
This means that once the program is deployed, the constructor cannot be changed.
It is executed every time the program is deployed or upgraded.


The `@noupgrade` annotation indicates that this program is not upgradable.
If the `@noupgrade` annotation is specified, the body of the constructor must be left blank.
The Leo compiler will automatically generate the appropriate code.
The constructor checks that the program's edition (version) is `0`.

Each program is automatically assigned a version when the network processes the deployment.
If the program is already deployed on the network, the assigned version will be non-zero, the constructor will fail to execute, and the deployment will be rejected.

## Deploying the Program
```
> leo deploy --broadcast
       Leo     3 statements before dead code elimination.
       Leo     3 statements after dead code elimination.
       Leo     The program checksum is: '[12u8, 65u8, 184u8, 236u8, 12u8, 123u8, 129u8, 53u8, 156u8, 105u8, 181u8, 154u8, 185u8, 201u8, 147u8, 232u8, 5u8, 12u8, 127u8, 88u8, 130u8, 105u8, 56u8, 198u8, 194u8, 9u8, 51u8, 107u8, 11u8, 148u8, 96u8, 114u8]'.
       Leo ✅ Compiled 'noupgrade_example.aleo' into Aleo instructions.
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
  • noupgrade_example.aleo  │ priority fee: 0  │ fee record: no (public fee)

⚙️ Actions:
  • Transaction(s) will NOT be printed to the console.
  • Transaction(s) will NOT be saved to a file.
  • Transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with deployment? · yes


🔧 You program 'noupgrade_example.aleo' has the following constructor.
──────────────────────────────────────────────
constructor:
assert.eq edition 0u16;
──────────────────────────────────────────────
Once it is deployed, it CANNOT be changed.

✔ Would you like to proceed? · yes

📦 Creating deployment transaction for 'noupgrade_example.aleo'...


📊 Deployment Summary for noupgrade_example.aleo
──────────────────────────────────────────────
  Total Variables:      17,276
  Total Constraints:    12,927
  Max Variables:        2,097,152
  Max Constraints:      2,097,152

💰 Cost Breakdown (credits)
  Transaction Storage:  0.886000
  Program Synthesis:    0.755075
  Namespace:            1.000000
  Constructor:          0.050000
  Priority Fee:         0.000000
  Total Fee:            2.691075
──────────────────────────────────────────────

📡 Broadcasting deployment for noupgrade_example.aleo...
💰Your current public balance is 93749987.434492 credits.

✔ This transaction will cost you 2.691075 credits. Do you want to proceed? · yes

✉️ Broadcasted transaction with:
  - transaction ID: 'at1gk55y5asypvckqnszf83de8ktkte4f0k5m7cqe4pplccrvnhnszs53mnmu'
  - fee ID: 'au1s7xwundv875gtj599l9v7wk8xdr6tncq8w8l4h65hqvj55k4svfqe0tc9k'
🔄 Searching up to 12 blocks to confirm transaction (this may take several seconds)...
Explored 1 blocks.
Transaction accepted.
✅ Deployment confirmed!
```

We can query the network to see that the deployment transaction has been accepted:
```
leo query transaction at1gk55y5asypvckqnszf83de8ktkte4f0k5m7cqe4pplccrvnhnszs53mnmu
```

## Attempting to Upgrade
To test the upgrade functionality, we can try to deploy the same program again.
You may also try to modify the program to add a new function.
Please refer to the [documentation](TODO) for more details on what constitutes a valid upgrade.

Now we will run
```
> leo upgrade --broadcast
       Leo     3 statements after dead code elimination.
       Leo     The program checksum is: '[12u8, 65u8, 184u8, 236u8, 12u8, 123u8, 129u8, 53u8, 156u8, 105u8, 181u8, 154u8, 185u8, 201u8, 147u8, 232u8, 5u8, 12u8, 127u8, 88u8, 130u8, 105u8, 56u8, 198u8, 194u8, 9u8, 51u8, 107u8, 11u8, 148u8, 96u8, 114u8]'.
       Leo ✅ Compiled 'noupgrade_example.aleo' into Aleo instructions.
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
  • noupgrade_example.aleo  │ priority fee: 0  │ fee record: no (public fee)

⚙️ Actions:
  • Transaction(s) will NOT be printed to the console.
  • Transaction(s) will NOT be saved to a file.
  • Transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with upgrade? · yes

📦 Creating deployment transaction for 'noupgrade_example.aleo'...


📊 Deployment Summary for noupgrade_example.aleo
──────────────────────────────────────────────
  Total Variables:      17,276
  Total Constraints:    12,927
  Max Variables:        2,097,152
  Max Constraints:      2,097,152

💰 Cost Breakdown (credits)
  Transaction Storage:  0.886000
  Program Synthesis:    0.755075
  Namespace:            1.000000
  Constructor:          0.050000
  Priority Fee:         0.000000
  Total Fee:            2.691075
──────────────────────────────────────────────
📡 Broadcasting upgrade for noupgrade_example.aleo...
💰Your current public balance is 93749961.436972 credits.

✔ This transaction will cost you 2.691075 credits. Do you want to proceed? · yes

✉️ Broadcasted transaction with:
  - transaction ID: 'at1geum6h7f7ym97d8z6k4zgnj7ycl0kegqygenquxmd999rys0wvgsxms7jg'
  - fee ID: 'au1wgjj8e2pa4swpt4myr99znypuag2w7c35ds3druuze5fm5tga5xspvjjq8'
🔄 Searching up to 12 blocks to confirm transaction (this may take several seconds)...
Explored 2 blocks.
Transaction rejected.
❌ Failed to upgrade program noupgrade_example.aleo: Transaction apparently not accepted.
```
