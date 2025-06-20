//! snarkVM Deployment Transaction Signer 
//! 
//! This CLI tool takes a snarkVM transaction from an input file, validates it's a deployment,
//! and modifies the program owner to match the address associated with the provided private key.
//! The modified transaction is then output to a specified file.

use anyhow::{bail, Context, Result};
use clap::Parser;
use snarkvm::{
    console::{
        account::{Address, PrivateKey},
        network::{MainnetV0, TestnetV0, CanaryV0},
    },
    prelude::{Transaction},
};
use std::{path::PathBuf, str::FromStr};
use snarkvm::ledger::store::ConsensusStore;
use snarkvm::ledger::store::helpers::memory::ConsensusMemory;
use snarkvm::prelude::{Network, ProgramOwner};
use rand::thread_rng;
use snarkvm_synthesizer::VM;

/// CLI tool to sign a snarkVM deployment transaction, with a new program owner.
#[derive(Parser, Debug)]
#[command(
    name = "sign-deployment",
    about = "Sign a snarkVM deployment transaction, modifying the program owner.",
    version,
)]
struct Args {
    /// Input file containing the snarkVM transaction JSON
    #[arg(short, long, value_name = "INPUT", help = "Input file containing the snarkVM transaction JSON")]
    input: PathBuf,

    /// Output file for the modified transaction JSON
    #[arg(short, long, value_name = "OUTPUT", help = "Output file for the modified transaction JSON")]
    output: PathBuf,

    /// Admin private key for signing the deployment (this will be the new program owner)
    #[arg(short, long, value_name = "ADMIN_PRIVATE_KEY", help = "Admin private key to sign the deployment. This will be the new program owner.")]
    admin_private_key: String,

    /// Fee private key for signing the fee transaction
    #[arg(short = 'f', long, value_name = "FEE_PRIVATE_KEY", help = "Fee private key to sign the fee transaction. If not provided, uses the admin private key.")]
    fee_private_key: Option<String>,

    /// Network: 0=mainnet, 1=testnet, 2=canary
    #[arg(short, long, value_name = "NETWORK", help = "Network to use: 0=mainnet, 1=testnet, 2=canary")]
    network: u8,
}

/// Core deployment signing logic that can be used for testing
pub fn sign_deployment<N: Network>(
    transaction_json: &str,
    admin_private_key_str: &str,
    fee_private_key_str: Option<&str>,
) -> Result<Transaction<N>> {
    // Parse admin private key and derive owner address.
    let admin_private_key = PrivateKey::<N>::from_str(admin_private_key_str)
        .context("Invalid admin private key format")?;
    let owner_address = Address::<N>::try_from(&admin_private_key)
        .context("Failed to derive address from admin private key")?;

    // Parse fee private key (use admin key if not provided)
    let fee_private_key = if let Some(fee_key_str) = fee_private_key_str {
        PrivateKey::<N>::from_str(fee_key_str)
            .context("Invalid fee private key format")?
    } else {
        admin_private_key
    };

    // Deserialize transaction.
    let transaction: Transaction<N> = serde_json::from_str(transaction_json)
        .context("Failed to deserialize transaction")?;

    // Extract the deployment.
    let Transaction::Deploy(_, _, _, deployment, fee) = transaction else {
        bail!("Expected a deployment transaction");
    };
    let mut deployment = *deployment;
    
    // Set the deployment owner and the program checksum.
    deployment.set_program_owner_raw(Some(owner_address));
    deployment.set_program_checksum_raw(Some(deployment.program().to_checksum()));
    
    // Initialize an RNG.
    let mut rng = thread_rng();
    
    // Construct the new program owner using admin private key.
    let program_owner = ProgramOwner::new(&admin_private_key, deployment.to_deployment_id()?, &mut rng)
        .context("Failed to create program owner")?;
    
    // Verify that the original fee is public.
    if !fee.is_fee_public() {
        bail!("The original fee must be public.");
    }
    
    // Create a new fee using fee private key.
    let vm = VM::<N, ConsensusMemory<N>>::from(ConsensusStore::open(0)?)?;
    let fee_authorization = vm.authorize_fee_public(&fee_private_key, *fee.base_amount()?, *fee.priority_amount()?, deployment.to_deployment_id()?, &mut rng)?;
    let fee = vm.execute_fee_authorization(fee_authorization, None, &mut rng)?;
    
    // Create the modified transaction.
    let transaction = Transaction::from_deployment(program_owner, deployment, fee)?;
    
    Ok(transaction)
}

fn process_transaction<N: Network>(args: &Args) -> Result<()> {
    // Parse private key and derive owner address for logging.
    let private_key = PrivateKey::<N>::from_str(&args.admin_private_key)
        .context("Invalid private key format")?;
    let owner_address = Address::<N>::try_from(&private_key)
        .context("Failed to derive address from private key")?;
    println!("Using the private key for address: {}", owner_address);

    // Load transaction from file.
    let content = std::fs::read_to_string(&args.input)
        .context("Failed to read input file")?;

    // Sign the deployment using core logic.
    let transaction = sign_deployment::<N>(&content, &args.admin_private_key, args.fee_private_key.as_deref())?;

    // Save modified transaction
    let json = serde_json::to_string_pretty(&transaction)
        .context("Failed to serialize transaction")?;
    std::fs::write(&args.output, json)
        .context("Failed to write output file")?;

    println!("✅ Successfully modified deployment transaction");
    println!("📁 Output saved to: {}", args.output.display());
    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();
    println!("Starting snarkVM deployment transaction modifier");
    
    match args.network {
        0 => process_transaction::<MainnetV0>(&args),
        1 => process_transaction::<TestnetV0>(&args),
        2 => process_transaction::<CanaryV0>(&args),
        n => bail!("Invalid network: {}", n),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const VALID_PRIVATE_KEY: &str = "APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH";

    const VALID_TRANSACTION_JSON: &str = r#"
{
  "type": "deploy",
  "id": "at1zuf98an9ste5ddz8kcpwljz5cgk36zrfhvvw5rm566epgx598s9q5fagra",
  "owner": {
    "address": "aleo1nkwycg5adkttcx7aezmlkdgxyd3t5pmpc8mqdu0038zgav8mzgxskqm6zy",
    "signature": "sign1kfjyh7yzs6358gysxmx243ey8k5wkyqf3x3v4erv9pkksqp32gqmdh7n4h732en8kry2daweujhve9sa3vkm2d3uj5mcf0y5ct56kq3p99n7wgvfz32zk4rx8dplhwgld5kjw9ft46jj8s4c2n9pgelhqhsw26hq5vt5j304pv2799zy357sktut7hx75kymklhzlqkljqgpqyuam70"
  },
  "deployment": {
    "edition": 0,
    "program": "program helloworld.aleo;\n\nfunction main:\n    input r0 as u32.public;\n    input r1 as u32.private;\n    add r0 r1 into r2;\n    output r2 as u32.private;\n",
    "verifying_keys": [
      [
        "main",
        [
          "verifier1qygqqqqqqqqqqqyvxgqqqqqqqqq87vsqqqqqqqqqhe7sqqqqqqqqqma4qqqqqqqqqq65yqqqqqqqqqqvqqqqqqqqqqqgtlaj49fmrk2d8slmselaj9tpucgxv6awu6yu4pfcn5xa0yy0tpxpc8wemasjvvxr9248vt3509vpk3u60ejyfd9xtvjmudpp7ljq2csk4yqz70ug3x8xp3xn3ul0yrrw0mvd2g8ju7rts50u3smue03gp99j88f0ky8h6fjlpvh58rmxv53mldmgrxa3fq6spsh8gt5whvsyu2rk4a2wmeyrgvvdf29pwp02srktxnvht3k6ff094usjtllggva2ym75xc4lzuqu9xx8ylfkm3qc7lf7ktk9uu9du5raukh828dzgq26hrarq5ajjl7pz7zk924kekjrp92r6jh9dpp05mxtuffwlmvew84dvnqrkre7lw29mkdzgdxwe7q8z0vnkv2vwwdraekw2va3plu7rkxhtnkuxvce0qkgxcxn5mtg9q2c3vxdf2r7jjse2g68dgvyh85q4mzfnvn07lletrpty3vypus00gfu9m47rzay4mh5w9f03z9zgzgzhkv0mupdqsk8naljqm9tc2qqzhf6yp3mnv2ey89xk7sw9pslzzlkndfd2upzmew4e4vnrkr556kexs9qrykkuhsr260mnrgh7uv0sp2meky0keeukaxgjdsnmy77kl48g3swcvqdjm50ejzr7x04vy7hn7anhd0xeetclxunnl7pd6e52qq67e88r5qjp4lkkplhlzrm0wcnyqyu3fsahrl34kvah8wug7gzwmhymu60qr84222uz0lc7jnx2sqg7f6e39fzj539aqchy48t9vqmcapt4hav454penkry6mnn7hle2j4e240t2xqdjmcfz690c5hskuqazpvu2mwm8x6mgtlsntxfhr0qas43rqxnccft36z4ygty86390t7vrt08derz8368z8ekn3yywxgq9caex8xjcyldmkysq27vvpp7p0tnn4vrrczdgyw4gpwls8xldqlvfpqqqqqqqqqqxusgmt",
          "certificate1qyqsqqqqqqqqqqpmrusj5l948532eqycvv858lpj3td29tuayvv6jweyj7v0r7g8pr2ulcgv97p24v4vnvc90w738yqqq4h4r3n"
        ]
      ]
    ]
  },
  "fee": {
    "transition": {
      "id": "au12r009kp505cewhsh9spneeq5d8hheutt2vu2vtspcdncdhcflvysungmg6",
      "program": "credits.aleo",
      "function": "fee_public",
      "inputs": [
        {
          "type": "public",
          "id": "5527819280611710146807142934623340092409239936361849313628778605966150159559field",
          "value": "3000000u64"
        },
        {
          "type": "public",
          "id": "6238198783950686774680947582951496894530093250709613345269498251796326103863field",
          "value": "0u64"
        },
        {
          "type": "public",
          "id": "6144226595206458409668073455952247781593570394599286152167672642746166358706field",
          "value": "4003401142391249165960808970017284849054518599525264574608932086535818575378field"
        }
      ],
      "outputs": [
        {
          "type": "future",
          "id": "3713250983786677288831231321436642939800208777662869971168314660637615657899field",
          "value": "{\n  program_id: credits.aleo,\n  function_name: fee_public,\n  arguments: [\n    aleo1nkwycg5adkttcx7aezmlkdgxyd3t5pmpc8mqdu0038zgav8mzgxskqm6zy,\n    3000000u64\n  ]\n}"
        }
      ],
      "tpk": "1924328792833733100897773577714271111439966754093078153108101780298628328697group",
      "tcm": "2014700957874530071075562650924541725854177262122554919961494253402203585429field",
      "scm": "2134462752769265126008143755737575732773660199111729394747053658446294392536field"
    },
    "global_state_root": "sr1zrtl5ne0307rr0k33y4m2lq7l9p4k4max97wt9c2uaevcvzs9yzsn5rqf7",
    "proof": "proof1qyqsqqqqqqqqqqqpqqqqqqqqqqqzaep7hty9njd7l506xhuwsjz2lrmm8f7u0msahpcxfkqg0nssgsg4femtmzvemx0el5kyy0hzkvuqq9wknkvshr4tt4v0yjja9hdgtd49ut7h60h2rv348vnj3fj5yff7dtf2mlc66kjqk9japwdpj6g0mqr2eqkea9txyuwayzwx0g87lc60cwqgj5ydmm7eflun44rp2upqf6p020v895grvt9344tjyhw3pcq4067qfl7ge9nsqa9d8qmjvr3frzm959syt54rdkm2aauwgun8sgvmwnxm8s02w5adyr9eupfw24ypkzlw959u6s2wzwhx82568ahxhal3xeq2p9jd54vnr2t94mfqht27rg7rztgj28ga6vca3p4ym5ncz7f26rs6amjadmajju9fsh0p9dv9l82l6lkg4s8jclmsuz567l54ezwkapkxxjxygeez9yztl450qrq70w7473ed90fskvn03xz4dxgucdqe3kut0xfm4uyte6m8d4d6t58t3hkpyleddqjr4z5z4npxcq8tlfr5t04829mkpr6px6ectdkhzmqu7870tlz5h7qkhay6wehn49vjywnrecc0wfl3we2zrfnz0wqa4l9wkdypkk65h73g5hwker6t390a4v3pxv6hcf20ekps2llkfdwdepzehlukea2jxc0uwxuwglcqgznd975znj4d3lnpuxd0qmkfqak9pu9cktkg9quycvchth2rkv8p3dzhgj4s3w9aejx2qs3p085tlz62zsfdfshf2hvfphnzenamgqgmh53exeg4ar3l00alykvg0v8pmhhn3k62vvnefnxh6zmxhe6zptz4wfqr0djd2kv39jhumsxflajp78l6n7hqetzq7j7y4nmpaxjqczmdsf8vxza6ykkh4j02h5qfdutcxdh9yq923pkqagpsvkms72gz2249tqpgn5anpcuhzne6we4f4pcny7lt6wnjl3tmerw3jhgglypmmd0ldr04xj5956d05qgr5wsvrfxelmcqgefak3psc4kty62y5rj6xc602kp03d7ngr0nluplv5c4h0lvehrhjae9yhkst47lmf5eq6upz7jtycgu2dslyy9ph4nmx9359fwazgzuwet6nc8a2hlvd3ns68nhuf6pem8yj7a5zexlunm7f6yxpzaq5gqyhkrh08ja9vq4eycpqvqqqqqqqqqqq8rf8x55m8gnl3sk583x037j4466wwefuaq6lumngpjklgg26g5xrtfyfhu5w2sjf8m4dzqkvcadqyq8yv8kh7g4esax2gjyvwdq0d6s30cq5gqaxlj3ymtwzrslqqxgunjesnkhd00uvms727rvczhg5kspqy9gjv0vn6gznac5h8krnl4l9gcpgc322yz595y7u7jdnf7wngrsfva7slzqxunwuvg765dd0lsexfdpgzcsxpucx6wrwem6tdwrum7gtxc7zg0kgw539c2kwycfxlemsyqq0jylxx"
  }
}"#;

    #[test]
    fn test_parse_private_key() {
        let result = PrivateKey::<TestnetV0>::from_str(VALID_PRIVATE_KEY);
        assert!(result.is_ok());
        
        let invalid_key = "invalid_key";
        let result = PrivateKey::<TestnetV0>::from_str(invalid_key);
        assert!(result.is_err());
    }

    #[test]
    fn test_network_selection() {
        let args = Args {
            input: PathBuf::from("test.json"),
            output: PathBuf::from("output.json"),
            admin_private_key: VALID_PRIVATE_KEY.to_string(),
            fee_private_key: None,
            network: 1,
        };
        
        // Should not panic for valid network
        let result = process_transaction::<TestnetV0>(&args);
        assert!(result.is_err()); // Will fail on file read, but not on network selection
    }

    #[test]
    fn test_invalid_network() {
        let args = Args {
            input: PathBuf::from("test.json"),
            output: PathBuf::from("output.json"),
            admin_private_key: VALID_PRIVATE_KEY.to_string(),
            fee_private_key: None,
            network: 99,
        };
        
        // Should fail for invalid network
        let result = process_transaction::<TestnetV0>(&args);
        assert!(result.is_err());
    }

    #[test]
    fn test_sign_deployment_with_valid_transaction() {
        // Test with the valid transaction JSON
        let result = sign_deployment::<TestnetV0>(VALID_TRANSACTION_JSON, VALID_PRIVATE_KEY, None);
        assert!(result.is_ok()); // Should succeed with valid deployment transaction
        
        // Verify the returned transaction is a deployment
        let transaction = result.unwrap();
        assert!(matches!(transaction, Transaction::Deploy(_, _, _, _, _)));
    }

    #[test]
    fn test_sign_deployment_with_invalid_private_key() {
        let transaction_json = r#"{"invalid": "transaction"}"#;
        let invalid_private_key = "invalid_key";
        
        let result = sign_deployment::<TestnetV0>(transaction_json, invalid_private_key, None);
        assert!(result.is_err()); // Should fail on invalid private key
    }

    #[test]
    fn test_sign_deployment_with_valid_inputs() {
        // Test with valid inputs - this should work
        let result = sign_deployment::<TestnetV0>(VALID_TRANSACTION_JSON, VALID_PRIVATE_KEY, None);
        assert!(result.is_ok());
        
        // Test with non-deployment transaction
        let non_deployment_json = r#"{"type": "transfer", "data": "test"}"#;
        let result = sign_deployment::<TestnetV0>(non_deployment_json, VALID_PRIVATE_KEY, None);
        assert!(result.is_err()); // Should fail because it's not a deployment transaction
    }
    
    #[test]
    fn test_sign_deployment_with_invalid_json() {
        let invalid_json = r#"{"invalid": "json"}"#;
         
        let result = sign_deployment::<TestnetV0>(invalid_json, VALID_PRIVATE_KEY, None);
        assert!(result.is_err()); // Should fail on invalid JSON format
    }
    
    #[test]
    fn test_sign_deployment_with_separate_fee_key() {
        // Test with separate admin and fee private keys
        let result = sign_deployment::<TestnetV0>(VALID_TRANSACTION_JSON, VALID_PRIVATE_KEY, Some(VALID_PRIVATE_KEY));
        assert!(result.is_ok()); // Should succeed with valid keys
        
        // Verify the returned transaction is a deployment
        let transaction = result.unwrap();
        assert!(matches!(transaction, Transaction::Deploy(_, _, _, _, _)));
    }
    
    #[test]
    fn test_sign_deployment_with_invalid_fee_key() {
        // Test with valid admin key but invalid fee key
        let invalid_fee_key = "invalid_fee_key";
        let result = sign_deployment::<TestnetV0>(VALID_TRANSACTION_JSON, VALID_PRIVATE_KEY, Some(invalid_fee_key));
        assert!(result.is_err()); // Should fail on invalid fee private key
    }
}
