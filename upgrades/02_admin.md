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
    @admin(address="aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px")
    async constructor() {}
    
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}
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
.
.
.
🔧 You program 'admin_example.aleo' has the following constructor.
──────────────────────────────────────────────
constructor:
assert.eq program_owner aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
──────────────────────────────────────────────
Once it is deployed, it CANNOT be changed.
.
.
.
```

If we query the network, we can see that the deployment transaction has been accepted.
```
leo query transaction at13226r67fxkf66qlrug4vp06yme4sw4n36f5ujcc8fzfkc6y78uys5yatra
```

## Upgrading the Program
To test the upgrade functionality, we can try to deploy the same program again.
You may also try to modify the program to add a new function.
Please refer to the [documentation](https://docs.leo-lang.org/guides/upgradability) for more details on what constitutes a valid upgrade.

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
