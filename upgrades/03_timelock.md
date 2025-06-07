# Time-locked Upgrades
In some scenarios, the pre-set upgrade configurations supported in Leo may not be sufficient for a specific use case.
In these cases, developers can implement their own upgrade logic using the `"custom"` configuration.

**Note. Extra care must be taken to ensure that logic is secure.**

## Initializing the Project

```
> leo new timelock_example
> cd timelock_example
```

We will modify the `program.json` file to use the `"custom"` configuration.

```json
{
  "program": "timelock_example.aleo",
  "version": "0.1.0",
  "description": "",
  "license": "MIT",
  "dependencies": null,
  "upgrade": {
    "mode": "custom"
  }
}
```

## The Program

```
> leo query block --latest-height
Leo ✅ Successfully retrieved data from 'http://localhost:3030/testnet/block/height/latest'.

1221
````


Now let's define the program.

```leo
// The 'timelock_example' program.
program timelock_example.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

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
       Leo ✅ Compiled 'timelock_example.aleo' into Aleo instructions
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
+-----------------------+---------+----------+--------------+-----------------+
| Program               | Upgrade | Base Fee | Priority Fee | Fee Record      |
+-----------------------+---------+----------+--------------+-----------------+
| timelock_example.aleo | custom  | auto     | 0            | no (public fee) |
+-----------------------+---------+----------+--------------+-----------------+

⚙️ Actions:
  - Your transaction(s) will NOT be printed to the console.
  - Your transaction(s) will NOT be saved to a file.
  - Your transaction(s) will be broadcast to http://localhost:3030
──────────────────────────────────────────────

✔ Do you want to proceed with deployment? · yes

📦 Creating deployment transaction for 'timelock_example.aleo'...

'timelock_example.aleo' uses a custom constructor for upgrades.
You MUST ensure that the constructor logic is thoroughly tested and audited.
✔ Do you want to proceed? · yes


📊 Deployment Stats for timelock_example.aleo
Total Variables:       17,234
Total Constraints:     12,927

Base deployment cost for 'timelock_example.aleo' is 3.015025 credits.

+-----------------------+----------------+
| timelock_example.aleo | Cost (credits) |
+-----------------------+----------------+
| Transaction Storage   | 0.991000       |
+-----------------------+----------------+
| Program Synthesis     | 0.754025       |
+-----------------------+----------------+
| Constructor           | 0.270000       |
+-----------------------+----------------+
| Namespace             | 1.000000       |
+-----------------------+----------------+
| Priority Fee          | 0.000000       |
+-----------------------+----------------+
| Total                 | 3.015025       |
+-----------------------+----------------+

📡 Broadcasting deployment for timelock_example.aleo...
💰Your current public balance is 93749840.718334 credits.

✔ This transaction will cost you 3.015025 credits. Do you want to proceed? · yes

✅ Successfully broadcast deployment with:
  - transaction ID: 'at19een08rx703keq3g90xc7rtlzt3ua0v289sdv4ujh42yrj6gjqzsmjrl4x'
  - fee ID: 'au158ar2ywknnzf0g02x3z4ex3phcqydjcaxa65pwxmnwc5fl03vc8sj2k509'
⏲️ Waiting for 15 seconds to allow the deployment to confirm...
```

If we query the network, we can see that the deployment transaction has been accepted.
```
> leo query transaction at19een08rx703keq3g90xc7rtlzt3ua0v289sdv4ujh42yrj6gjqzsmjrl4x
       Leo ✅ Successfully retrieved data from 'http://localhost:3030/testnet/transaction/at19een08rx703keq3g90xc7rtlzt3ua0v289sdv4ujh42yrj6gjqzsmjrl4x'.

{
  type: deploy,
  id: at19een08rx703keq3g90xc7rtlzt3ua0v289sdv4ujh42yrj6gjqzsmjrl4x,
  owner: {
    address: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px,
    signature: sign1f4ku7cvk3d44nn27ayen7ch7ud0t0nxjv6phw9wd5f49jpp0uyqdh3qemujsfgpr7l5sp3sdrmcnkksn5sp0a4ucajnnv0n7nvap5qyr22qjwn4zc0pzv87twjygsz9m7ekljmuw4jpzf68rwuq99r0tp735vs6220q7tp60nr7llkwstcvu49wdhydx5x2s3sftjskzawhqvs5rv9a
  },
  deployment: {
    edition: 0,
    program: program timelock_example.aleo;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

constructor:
    gt edition 0u16 into r0;
    branch.eq r0 false to end_then_0_0;
    gte block.height 1300u32 into r1;
    assert.eq r1 true;
    branch.eq true true to end_otherwise_0_1;
    position end_then_0_0;
    position end_otherwise_0_1;
,
    verifying_keys: [
      [
        main,
        [
          verifier1qygqqqqqqqqqqqyvxgqqqqqqqqq87vsqqqqqqqqqhe7sqqqqqqqqqma4qqqqqqqqqq65yqqqqqqqqqqvqqqqqqqqqqqgtlaj49fmrk2d8slmselaj9tpucgxv6awu6yu4pfcn5xa0yy0tpxpc8wemasjvvxr9248vt3509vpk3u60ejyfd9xtvjmudpp7ljq2csk4yqz70ug3x8xp3xn3ul0yrrw0mvd2g8ju7rts50u3smue03gp99j88f0ky8h6fjlpvh58rmxv53mldmgrxa3fq6spsh8gt5whvsyu2rk4a2wmeyrgvvdf29pwp02srktxnvht3k6ff094usjtllggva2ym75xc4lzuqu9xx8ylfkm3qc7lf7ktk9uu9du5raukh828dzgq26hrarq5ajjl7pz7zk924kekjrp92r6jh9dpp05mxtuffwlmvew84dvnqrkre7lw29mkdzgdxwe7q8z0vnkv2vwwdraekw2va3plu7rkxhtnkuxvce0qkgxcxn5mtg9q2c3vxdf2r7jjse2g68dgvyh85q4mzfnvn07lletrpty3vypus00gfu9m47rzay4mh5w9f03z9zgzgzhkv0mupdqsk8naljqm9tc2qqzhf6yp3mnv2ey89xk7sw9pslzzlkndfd2upzmew4e4vnrkr556kexs9qrykkuhsr260mnrgh7uv0sp2meky0keeukaxgjdsnmy77kl48g3swcvqdjm50ejzr7x04vy7hn7anhd0xeetclxunnl7pd6e52qxhgjjh5v2c8kwv5cvqqyh0fux6tm7ewuxzqupxt4tena434axph9mqz4tlg50w38pdpf5ltjaa8kqq54h644cf0cr6aqtdprpzjjd4h4rlfn43uvd7z93r7hyk5fh9zspmcz2fgkwg7xx2y03wu5ee6p5qazpvu2mwm8x6mgtlsntxfhr0qas43rqxnccft36z4ygty86390t7vrt08derz8368z8ekn3yywxgqgua2nstn4lsn4fsvwsgm9ln6ne44z2x02pxd8c30y8e9g02sc072fpsqqqqqqqqqrpd8h0,
          certificate1qyqsqqqqqqqqqqx45k5m2mhgur4d56xy3aqmpdsudf0l2vkl7t4p964epc9z563h364wrn9ah8rvrgewzwf8lzzxpwqqq8kyckr
        ]
      ]
    ],
    program_checksum: [
      94u8,
      103u8,
      218u8,
      226u8,
      4u8,
      153u8,
      164u8,
      219u8,
      239u8,
      17u8,
      184u8,
      136u8,
      84u8,
      196u8,
      115u8,
      62u8,
      190u8,
      58u8,
      46u8,
      249u8,
      38u8,
      92u8,
      182u8,
      68u8,
      220u8,
      45u8,
      193u8,
      97u8,
      53u8,
      226u8,
      73u8,
      1u8
    ],
    program_owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px
  },
  fee: {
    transition: {
      id: au158ar2ywknnzf0g02x3z4ex3phcqydjcaxa65pwxmnwc5fl03vc8sj2k509,
      program: credits.aleo,
      function: fee_public,
      inputs: [
        {
          type: public,
          id: 5180072607645386331124113034456056537539097960258464625036718442645296704710field,
          value: 3015025u64
        },
        {
          type: public,
          id: 4314517510403563084295509218711291191703771871112577164797600865408601804934field,
          value: 0u64
        },
        {
          type: public,
          id: 7526786230160597006406607702903195122780808685131184895742537233403432200981field,
          value: 1689897880099949376631143172729341710964011151979790505735238307092737709513field
        }
      ],
      outputs: [
        {
          type: future,
          id: 7665671191320552693942275786616086186639942619785675386149196849000560759881field,
          value: {
  program_id: credits.aleo,
  function_name: fee_public,
  arguments: [
    aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px,
    3015025u64
  ]
}
        }
      ],
      tpk: 108391179355953573574577934157475992154687825862117051210703591026876249957group,
      tcm: 6438302316424669435557230363917776730305787470346556216780815901597369789626field,
      scm: 4166889809692200383179423305995019930570834548278097381383201990131307401726field
    },
    global_state_root: sr1cr5k95h7waf0yhyjqt2jzc7xt6svl8n04264kpw6znmyt69eeups80as6f,
    proof: proof1qyqsqqqqqqqqqqqpqqqqqqqqqqqzkgwdlpf4djzd7aw22n2qa00epgw9vr8hm2vnf2y7789qd4tejj4r78y30eh68ygvhk89xn0mtucqq9uhvaecq9dj307shm4g8ph0rw6mynca2jmk8069t23zjtudgn87gd2aawydukhxwp4957tvlc80uqywhug5fed8xwcmyqmm9ux2sheythnlzxxpsau7pcz0yshzddka9pn4xaasppqkrarem4knzdyg8uqj0g0cuef9uld3e87exkv9kktg3dfmstqsqstev3msanp3yunfqlzh8j2st6vcemkwyefww8weug5p4yaccxd0z8z5uewl56d9e02dsfu5v3jnp09ewfm4m6epsl2jxdsqd3w4s0pv79ajvweqrscd59tsz2v627zkx22r6z9256upd0rx8sux9hkyjq4482gfjxetae60qgcurxpdq0fvfaxj497520pmcgvkq8d24f5xvhnsnscap8shsppkur8spylt5wxwyzt0pw25wrmg6szkh2nhl8wm8u6uzwagju6lsv5z2qfjchaef6cqlv00e9xka4ew9jwsgwc762m64zkfurtczervt5fkdxtm0l5u0k77rvwufgn9r88fwgq3vxeu7t28gll8qv58nxehuuc0jtxcq85fg0vlsr37n330ra6nzan8ty9uzzdtvrm5v0r4esay36qq9gx590rae766jtffpk4s042myyh8hk38a8yrr3s8tmnuv2ntvqpkfk8w9v25wg2vtamv7qvcthq76hm4qntwq4f3v4gs7swmmyx4vqef64t9dww5ge8l0sh8lja2mayy6prnhqesfkjclghzrkdywt60q03v2sgk0fhl6hg46vgwk9ppcux2n7k9q648m3kce3dd47wj9s4qcxgvad5jerujjkam8mh8qmwc942hf29hdmv7ff0r56ha9qrpk2ggd6elljpl05rgmxvukfqnvgq8xduh5r52fx9ylsnutwhzfxpvauy0cf0xckzcjy5jxt5du7ca7jhh5pjyhu9kzxy926ld90z4cv0kvyktvaa002z5u9fh96qjzm8kcjxsgf4acvl99kadn6zxxhm2la7yqpqjt4pg60vul377jex2hz8hmgr89ca5esxkvxy2nueyah4lpu2q08vtxzzd3us9scqqx6yk60ur2lnr0znl577alhdtfe0xzvehzpgvqvqqqqqqqqqqqcmzvxatg8jaj3t5xq98x5fcjqw20vs003ntx600ha72v2gqr457mrrm90elgy9wqkldh6z4t858qqqrkq6j3mqusdj9mvhjya9vq96r4e622q5uqgzuu0uchc3yl8nmrwwcdtz4sslqn99k0363txp49qsqqyzwwrplw9k3fmrhl3me7xvx29tsul9g9smv2whc5hnuhllnvhas9d46v3we40jnjr3qusa38d440h2rhxcux7nll3y48a6drgxden94u834fxzrz5wv6ka4rfqe89uhsqqq2nz09h
  }
}
```


After the block height bound is reached, the program can be upgraded.
You can verify this by first modifying the program, running `leo upgrade --broadcast`, and then 

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



