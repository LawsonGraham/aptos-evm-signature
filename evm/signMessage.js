const { ethers, Signature, SigningKey, hashMessage, keccak256, concat, toUtf8Bytes, MessagePrefix, sha256} = require('ethers');
require('dotenv').config();

// Define the user's Ethereum private key (secure this in a real environment)
const privateKey = process.env.ETHEREUM_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey);

// The message you want to sign (in this case, the Aptos address) WITH `0x` prefix
const aptosAddress = process.env.APTOS_ADDRESS;

// Function to sign the message using the Ethereum wallet
async function signMessage() {
    // Sign the message (this implcitly hashes the message)
    const publicKey = SigningKey.computePublicKey(process.env.ETHEREUM_PRIVATE_KEY);

    console.log("Pub key: ", publicKey);
    console.log("Address: ", wallet.address)
    console.log("Message: ", aptosAddress);
    console.log("Hashed Message: ", keccak256(aptosAddress));

    // const signature = await wallet.signMessage(message);
    // We use the signing key for now so that we can DIRECTLY sign the hash of the message, not
    // the address preappended by some standard Ethereum message prefixes then hashed
    const signature = (new SigningKey(process.env.ETHEREUM_PRIVATE_KEY)).sign(keccak256(aptosAddress));
    console.log('Signature:', signature);

    // Split the signature into r, s, and v components
    const signatureSplit = Signature.from(signature);
    console.log('r:', signatureSplit.r);
    console.log('s:', signatureSplit.s);
    console.log('v:', signatureSplit.v);  // Recovery ID (1 or 0, typically)

    return signatureSplit;
}

// Call the function
signMessage().then((signature) => {
    console.log('Signature components:', signature);
}).catch((error) => {
    console.error('Error signing message:', error);
});
