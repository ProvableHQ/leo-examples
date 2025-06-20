# Admin-Driven Upgrades
In many production scenarios, developers will want to deploy a program that is upgradable by a designated administrator.
Leo provides a configuration for this use case.

Be sure to review the **Security Practices** section.

## Initializing the Project

```
> cd admin_example
```
This example has already been set up for you.
However, if you were to initialize a new project, you would manually edit the `program.json` file to use the `"admin"` configuration.
The Leo compiler uses this configuration to ensure that your program is well-formed for the `"admin"` upgrade mode.

```json
{
  "program": "admin_example.aleo",
  "version": "0.1.0",
  "description": "",
  "license": "MIT",
  "dependencies": null,
  "upgrade": {
    "mode": "admin",
    "address": "aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px"
  }
}
```

The `"address"` field is the address of the administrator.
The private key associated with this address must sign the deployment transaction associated with upgrade.

## The Program

```leo
// The 'admin_example' program.
program admin_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    async constructor() {
        assert_eq(self.program_owner, aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px);
    }
}
```

The constructor checks that the program's owner is the administrator.
If a program is deployed by a different address, the constructor will fail to execute, and the deployment will be rejected.

## Deploying the Program
```
> leo deploy --broadcast
       Leo     6 statements before dead code elimination.
       Leo     6 statements after dead code elimination.
       Leo ✅ Compiled 'admin_example.aleo' into Aleo instructions
Attempting to determine the consensus version from the latest block height at http://localhost:3030...

🛠️  Deployment Plan Summary
──────────────────────────────────────────────
🔧 Configuration:
  Private Key:       APrivateKey1zkp8CZNn3yeC...
  Address:           aleo1rhgdu77hgyqd3xjj8uc...
  Endpoint:          http://localhost:3030
  Network:           testnet
  Consensus Version: 8

📦 Deployment Tasks:
+--------------------+---------+----------+--------------+-----------------+
| Program            | Upgrade | Base Fee | Priority Fee | Fee Record      |
+--------------------+---------+----------+--------------+-----------------+
| admin_example.aleo | admin   | auto     | 0            | no (public fee) |
+--------------------+---------+----------+--------------+-----------------+

⚙️ Actions:
  - Your transaction(s) will NOT be printed to the console.
  - Your transaction(s) will NOT be saved to a file.
  - Your transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with deployment? · yes

📦 Creating deployment transaction for 'admin_example.aleo'...

ANYONE with access to the private key for 'admin_example.aleo' can upgrade 'aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px'.
You MUST ensure that the key is securely stored and operated.
✔ Do you want to proceed? · yes


📊 Deployment Stats for admin_example.aleo
Total Variables:       17,114
Total Constraints:     12,927

Base deployment cost for 'admin_example.aleo' is 2.713025 credits.

+---------------------+----------------+
| admin_example.aleo  | Cost (credits) |
+---------------------+----------------+
| Transaction Storage | 0.912000       |
+---------------------+----------------+
| Program Synthesis   | 0.751025       |
+---------------------+----------------+
| Constructor         | 0.050000       |
+---------------------+----------------+
| Namespace           | 1.000000       |
+---------------------+----------------+
| Priority Fee        | 0.000000       |
+---------------------+----------------+
| Total               | 2.713025       |
+---------------------+----------------+

📡 Broadcasting deployment for admin_example.aleo...
💰Your current public balance is 93749916.175809 credits.

✔ This transaction will cost you 2.713025 credits. Do you want to proceed? · yes

✅ Successfully broadcast deployment with:
  - transaction ID: 'at12q3qa2fhlzanekqn66pr35palhfvvv2pke25lzy3vmwlucaa55zs6rhhah'
  - fee ID: 'au10g7rnc2frs7tjqtwdkfweqgpdyj90jzg6sm7c9qx4kfea78u7cpqth8cd5'
⏲️ Waiting for 15 seconds to allow the deployment to confirm...
```

If we query the network, we can see that the deployment transaction has been accepted.
```
leo query transaction at12q3qa2fhlzanekqn66pr35palhfvvv2pke25lzy3vmwlucaa55zs6rhhah
```

## Upgrading the Program
First, let's attempt to upgrade the program using a different private key.
We will use this private key: `APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh`, whose address is `aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t`.
We can verify that this address has a balance by querying the network.
```
leo query program credits.aleo --mapping_value account aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t
```

First, modify the program by adding a `transition` of your choice.
If we run 
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

This can be especially useful if you are storing your admin key on a seperate, air-gapped machine.
