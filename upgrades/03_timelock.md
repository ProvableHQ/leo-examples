# Time-locked Upgrades
In some scenarios, the pre-set upgrade configurations supported in Leo may not be sufficient for a specific use case.
In these cases, developers can implement their own upgrade logic using the `"custom"` configuration.

**Note: Constructors are immutable and custom constructors can be tricky to get right. Extra care must be taken to ensure that logic is secure.**


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
Note that this value will change as the network produces new blocks.

Now let's define the program.
```leo
program timelock_example.aleo {
    @custom
    async constructor() {
        if self.edition > 0u16 {
            assert(block.height >= 1300u32);
        }
    }
    
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}
}
```

Note: The block height can be set to any value. `1300u32` is used for demonstration purposes.
For any upgrade, where the edition is greater than zero, then the constructor checks that the block height is greater than or equal to `1300u32`.

## Deploying the Program
```
> leo deploy --broadcast
.
.
.
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
.
.
.
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



