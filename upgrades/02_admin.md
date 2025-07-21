# Admin-Driven Upgrades
In many production scenarios, developers will want to deploy a program that is upgradable by a designated administrator.
Leo provides a configuration for this use case.

Be sure to review the **Security Practices** section.

## Initializing the Project
You may either use the existing `admin` project
```
> cd admin
```
or create a new Leo project with the following command:
```
> leo new admin
```

## The Program

```leo
program admin_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    transition foo() {}

    // This is the constructor for the program.
    @admin(address="aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px")
    async constructor() {}
}
```

In this example, we annotate the `constructor` with the `@admin` annotation.
The `"address"` field is the address of the administrator.
The private key associated with this address must sign the deployment transaction associated with upgrade.

The Leo compiler will generate AVM code that checks that the program's owner is the administrator.
If a program is deployed by a different address, the constructor will fail to execute, and the deployment will be rejected.

## Deploying the Program
```
> leo deploy --broadcast
       Leo     4 statements before dead code elimination.
       Leo     4 statements after dead code elimination.
       Leo     The program checksum is: '[154u8, 71u8, 238u8, 60u8, 58u8, 58u8, 43u8, 14u8, 200u8, 117u8, 94u8, 228u8, 30u8, 90u8, 89u8, 223u8, 172u8, 165u8, 224u8, 175u8, 32u8, 91u8, 130u8, 69u8, 230u8, 178u8, 27u8, 46u8, 106u8, 63u8, 0u8, 235u8]'.
       Leo ✅ Compiled 'admin_example.aleo' into Aleo instructions.
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
  • admin_example.aleo  │ priority fee: 0  │ fee record: no (public fee)

⚙️ Actions:
  • Transaction(s) will NOT be printed to the console.
  • Transaction(s) will NOT be saved to a file.
  • Transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with deployment? · yes


🔧 You program 'admin_example.aleo' has the following constructor.
──────────────────────────────────────────────
constructor:
assert.eq program_owner aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
──────────────────────────────────────────────
Once it is deployed, it CANNOT be changed.

✔ Would you like to proceed? · yes

📦 Creating deployment transaction for 'admin_example.aleo'...


📊 Deployment Summary for admin_example.aleo
──────────────────────────────────────────────
  Total Variables:      30,949
  Total Constraints:    22,700
  Max Variables:        2,097,152
  Max Constraints:      2,097,152

💰 Cost Breakdown (credits)
  Transaction Storage:  1.661000
  Program Synthesis:    1.341225
  Namespace:            1.000000
  Constructor:          0.050000
  Priority Fee:         0.000000
  Total Fee:            4.052225
──────────────────────────────────────────────

📡 Broadcasting deployment for admin_example.aleo...
💰Your current public balance is 93749981.879517 credits.

✔ This transaction will cost you 4.052225 credits. Do you want to proceed? · yes

✉️ Broadcasted transaction with:
  - transaction ID: 'at13226r67fxkf66qlrug4vp06yme4sw4n36f5ujcc8fzfkc6y78uys5yatra'
  - fee ID: 'au16cpp3addtpamknz4mghn8dzhkpde8ak0990485z464twdu3hkq9sk6jnqv'
🔄 Searching up to 12 blocks to confirm transaction (this may take several seconds)...
Explored 1 blocks.
Transaction accepted.
✅ Deployment confirmed!
```

If we query the network, we can see that the deployment transaction has been accepted.
```
leo query transaction at13226r67fxkf66qlrug4vp06yme4sw4n36f5ujcc8fzfkc6y78uys5yatra
```

## Upgrading the Program
First, let's attempt to upgrade the program using a different private key.
We will use this private key: `APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh`, whose address is `aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t`.
We can verify that this address has a balance by querying the network.
```
leo query program credits.aleo --mapping-value account aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t
```

First, modify the source code by adding a `transition` of your choice.
Now, if we run 
```
> leo upgrade --broadcast --private-key APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh
```
we will find that the transaction is rejected.

Now if we run
```
> leo upgrade --broadcast
```
we will find that the transaction is accepted. 
We can verify that the program has been upgraded by querying the network.
```
leo query program admin_example.aleo
```

## Security Practices
- The administrator's private key must be kept secure and not shared with anyone.
- We recommend that deployment transactions are signed offline and broadcasted to the network using a secure method.

In the `admin` directory, you'll find a Rust CLI utility `sign-deployment` which can be used to sign deployment transactions with a separate private key.

This can be especially useful if you are storing your admin key on a separate, air-gapped machine.
