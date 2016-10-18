const PaillierPrivateKeyRing = require('./paillier/PaillierPrivateKeyRing');
const PaillierPublicKeyRing = require('./paillier/PaillierPublicKeyRing');
const sk_ring = PaillierPrivateKeyRing.load_from_file("test");
const pk_ring = PaillierPublicKeyRing.load_from_file();

console.log("Private Keys:");
console.log(sk_ring.keys);
console.log();
console.log("Public Keys:");
console.log(pk_ring.keys);