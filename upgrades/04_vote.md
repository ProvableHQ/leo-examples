# Vote Example Tutorial
In some scenarios, developers may wish to use more sophisticated governance mechanisms to manage program updates. 
In these cases, developers can use the `"checksum"` configuration.
At a high-level, every AVM program has a unique checksum associated with it. We can use this checksum to pin down the expected contents of a program.

This tutorial details a "toy" voting system for program updates on the Aleo network.
In production, extra care should be taken to ensure that the governance mechanism is secure and robust.

## Initializing the Project
```
> cd vote_example
```
This example has already been set up for you.
However, if you were to initialize a new project, you would manually edit the `program.json` file to use the `"checksum"` configuration.
The Leo compiler uses this configuration to ensure that your program is well-formed for the `"checksum"` upgrade mode.

```json
{
  "program": "vote_example.aleo",
  "version": "0.1.0",
  "description": "",
  "license": "MIT",
  "dependencies": [
    {
      "name": "basic_voting.aleo",
      "location": "local",
      "path": "./basic_voting",
      "edition": null
    }
  ],
  "dev_dependencies": null,
  "upgrade": {
    "mode": "checksum",
    "mapping": "basic_voting.aleo/approved_checksum",
    "key": "true"
  }
}
```

The `"mapping"` field specifies the program and mapping to look at for the approved checksum.
The compiler will check that this mapping exists in the program.
The `"key"` field specifies the hard-coded key that will be accessed to retrieve the expected checksum.

## Program Overview

The voting program is a non-upgradable program (see `01_noupgrade.md` for more details) that allows users to propose the expected checksum and vote on it them.
Note that the voting program is intended for educational purposes and is **NOT** suitable for production use.
See `vote_example/basic_voting` for the source code.

The main program (`vote_example.aleo`) imports the `basic_voting` program and queries the `approved_checksum` mapping to determine the expected checksum for the program.
```leo
import basic_voting.aleo;

program vote_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    async constructor() {
        if self.edition > 0u16 {
            let expected: [u8; 32] = Mapping::get(basic_voting.aleo/approved_checksum, true);
            assert_eq(self.checksum, expected);
        }
    }
}
```

## Step-by-Step Guide

### Deploying the Program

First, deploy both programs to the Aleo network:

```bash
leo deploy --broadcast
```

### Developing the Upgrade

We will now modify our program by adding a new transition called `foo`.
```leo
transition foo() {}
```

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
       Leo     The program checksum is: '[139u8, 175u8, 223u8, 29u8, 214u8, 159u8, 77u8, 20u8, 120u8, 41u8, 188u8, 201u8, 170u8, 149u8, 63u8, 73u8, 208u8, 76u8, 207u8, 13u8, 83u8, 167u8, 134u8, 118u8, 110u8, 126u8, 131u8, 235u8, 12u8, 54u8, 155u8, 106u8]'.
       Leo ✅ Compiled 'vote_example.aleo' into Aleo instructions.
```

The checksum is: `[139u8, 175u8, 223u8, 29u8, 214u8, 159u8, 77u8, 20u8, 120u8, 41u8, 188u8, 201u8, 170u8, 149u8, 63u8, 73u8, 208u8, 76u8, 207u8, 13u8, 83u8, 167u8, 134u8, 118u8, 110u8, 126u8, 131u8, 235u8, 12u8, 54u8, 155u8, 106u8]`

### Invalid Upgrade Attempts

Now let's try to deploy the program without going through the voting process.
This will fail because there is no approved checksum set in the `basic_voting` program.
```bash
leo upgrade --broadcast
```

### Voting on the Upgrade

To propose the upgrade, we need to call the `propose` transition in the `basic_voting` program.
```bash
leo execute basic_voting.aleo propose "[139u8, 175u8, 223u8, 29u8, 214u8, 159u8, 77u8, 20u8, 120u8, 41u8, 188u8, 201u8, 170u8, 149u8, 63u8, 73u8, 208u8, 76u8, 207u8, 13u8, 83u8, 167u8, 134u8, 118u8, 110u8, 126u8, 131u8, 235u8, 12u8, 54u8, 155u8, 106u8]" --broadcast
```

Then we'll need to vote on the proposal.
We'll vote once with our own address.
```bash
leo execute basic_voting.aleo vote "[139u8, 175u8, 223u8, 29u8, 214u8, 159u8, 77u8, 20u8, 120u8, 41u8, 188u8, 201u8, 170u8, 149u8, 63u8, 73u8, 208u8, 76u8, 207u8, 13u8, 83u8, 167u8, 134u8, 118u8, 110u8, 126u8, 131u8, 235u8, 12u8, 54u8, 155u8, 106u8]" true --broadcast
```
And then once more with a different address.
```bash
leo execute basic_voting.aleo vote "[139u8, 175u8, 223u8, 29u8, 214u8, 159u8, 77u8, 20u8, 120u8, 41u8, 188u8, 201u8, 170u8, 149u8, 63u8, 73u8, 208u8, 76u8, 207u8, 13u8, 83u8, 167u8, 134u8, 118u8, 110u8, 126u8, 131u8, 235u8, 12u8, 54u8, 155u8, 106u8]" true --broadcast --private-key 
APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh
```
Note. The key `APrivateKey1zkp2RWGDcde3efb89rjhME1VYA8QMxcxep5DShNBR6n8Yjh` will always have credits on a local snarkOS development network.

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






