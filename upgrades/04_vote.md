# Vote Example Tutorial
In some scenarios, developers may wish to use more sophisticated governance mechanisms to manage program updates. 
In these cases, developers can use the `"checksum"` configuration.
At a high-level, every AVM program has a unique checksum associated with it. We can use this checksum to pin down the expected contents of a program.

This tutorial details a "toy" voting system for program updates on the Aleo network.
In production, extra care should be taken to ensure that the governance mechanism is secure and robust.

## Initializing the Project
You may either use the existing `vote` project
```
> cd vote
```
or create a new Leo project with the following command:
```
> leo new vote 
```



## Program Overview

This project will contain two programs: `basic_voting.aleo` and `vote_example.aleo`.

The `basic_voting` program is a non-upgradable program (see `01_noupgrade.md` for more details) that allows users to propose the expected checksum and vote on it them.
Note that the voting program is intended for educational purposes and is **NOT** suitable for production use.
See `vote_example/basic_voting` for the source code.

The main program (`vote_example.aleo`) imports the `basic_voting` program and queries the `approved_checksum` mapping to determine the expected checksum for the program.
```leo
import basic_voting.aleo;

program vote_example.aleo {
    @checksum(mapping="basic_voting.aleo/approved_checksum", key="true")
    async constructor() {}
    
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}
}
```

The `"mapping"` field specifies the program and mapping to look at for the approved checksum.
The `"key"` field specifies the hard-coded key that will be accessed to retrieve the expected checksum.
The Leo compiler will generate AVM code that checks that the program's checksum matches the approved checksum in the `basic_voting` program.

## Step-by-Step Guide

### Deploying the Program

First, deploy both programs to the Aleo network:

```
leo deploy --broadcast
.
.
.
🔧 Your program 'vote_example.aleo' has the following constructor.
──────────────────────────────────────────────
constructor:
branch.eq edition 0u16 to end;
get basic_voting.aleo/approved_checksum[true] into r0;
assert.eq checksum r0;
position end;
──────────────────────────────────────────────
Once it is deployed, it CANNOT be changed.
.
.
.
```

### Developing the Upgrade
To test the upgrade functionality, we can try to deploy the same program again.
You may also try to modify the program to add a new function.
Please refer to the [documentation](https://docs.leo-lang.org/guides/upgradability) for more details on what constitutes a valid upgrade.

`leo build` will compile the program and tell us what the checksum is. This will be used to propose the upgrade.

```bash
> leo build
       Leo     
43 statements before dead code elimination.
       Leo     43 statements after dead code elimination.
       Leo     The program checksum is: '[236u8, 187u8, 121u8, 19u8, 43u8, 151u8, 43u8, 148u8, 186u8, 84u8, 247u8, 47u8, 61u8, 191u8, 25u8, 144u8, 160u8, 154u8, 95u8, 43u8, 177u8, 250u8, 189u8, 109u8, 243u8, 208u8, 52u8, 113u8, 202u8, 82u8, 216u8, 66u8]'.
       Leo ✅ Compiled 'basic_voting.aleo' into Aleo instructions.
       Leo     
12 statements before dead code elimination.
       Leo     12 statements after dead code elimination.
       Leo     The program checksum is: '[33u8, 48u8, 194u8, 27u8, 174u8, 61u8, 90u8, 33u8, 29u8, 160u8, 246u8, 222u8, 188u8, 64u8, 174u8, 4u8, 25u8, 255u8, 119u8, 147u8, 218u8, 75u8, 182u8, 78u8, 213u8, 89u8, 77u8, 100u8, 247u8, 125u8, 72u8, 3u8]'.
       Leo ✅ Compiled 'vote_example.aleo' into Aleo instructions.
```

The checksum that we will propose is: `[33u8, 48u8, 194u8, 27u8, 174u8, 61u8, 90u8, 33u8, 29u8, 160u8, 246u8, 222u8, 188u8, 64u8, 174u8, 4u8, 25u8, 255u8, 119u8, 147u8, 218u8, 75u8, 182u8, 78u8, 213u8, 89u8, 77u8, 100u8, 247u8, 125u8, 72u8, 3u8]`

### Invalid Upgrade Attempts

Now let's try to deploy the program without going through the voting process.
This will fail because there is no approved checksum set in the `basic_voting` program.
```bash
leo upgrade --broadcast
```

### Voting on the Upgrade

To propose the upgrade, we need to call the `propose` transition in the `basic_voting` program.
```bash
leo execute basic_voting.aleo propose "[33u8, 48u8, 194u8, 27u8, 174u8, 61u8, 90u8, 33u8, 29u8, 160u8, 246u8, 222u8, 188u8, 64u8, 174u8, 4u8, 25u8, 255u8, 119u8, 147u8, 218u8, 75u8, 182u8, 78u8, 213u8, 89u8, 77u8, 100u8, 247u8, 125u8, 72u8, 3u8]" --broadcast
```

Then we'll need to vote on the proposal.
We'll vote once with our own address.
```bash
leo execute basic_voting.aleo vote "[33u8, 48u8, 194u8, 27u8, 174u8, 61u8, 90u8, 33u8, 29u8, 160u8, 246u8, 222u8, 188u8, 64u8, 174u8, 4u8, 25u8, 255u8, 119u8, 147u8, 218u8, 75u8, 182u8, 78u8, 213u8, 89u8, 77u8, 100u8, 247u8, 125u8, 72u8, 3u8]" true --broadcast
```
And then once more with a different address.
```bash
leo execute basic_voting.aleo vote "[33u8, 48u8, 194u8, 27u8, 174u8, 61u8, 90u8, 33u8, 29u8, 160u8, 246u8, 222u8, 188u8, 64u8, 174u8, 4u8, 25u8, 255u8, 119u8, 147u8, 218u8, 75u8, 182u8, 78u8, 213u8, 89u8, 77u8, 100u8, 247u8, 125u8, 72u8, 3u8]" true --broadcast --private-key 
APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh
```
Note: The key `APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh` will always have credits on a local snarkOS development network.

### Another Invalid Upgrade Attempt
Now let's try to deploy the program, but modify the code so that the checksum does not match the approved checksum.
For example, we can change the name of the `foo` transition to `foo2`.
If we attempt to upgrade the program now, it will fail because the checksum does not match the approved checksum.
```bash
leo upgrade --skip basic_voting.aleo --broadcast
```

## A Successful Upgrade
Finally, let's modify the program to match the approved checksum and deploy it.
We'll change the `foo2` transition back to its original name `foo` and then run the upgrade command again.
```bash
leo upgrade --skip basic_voting.aleo --broadcast
```

We can verify by checking that the new program is present in the network.
```bash
leo query program vote_example.aleo
```






