const C = require('crypto-js');
const fs = require('fs');

var PaillierPrivateKeyRing = function (key_ring_json)
{
	this.keys = key_ring_json;
};

PaillierPrivateKeyRing.key_dir = "./keys";
//The AES encrypted key ring file.
PaillierPrivateKeyRing.keyring_file = PaillierPrivateKeyRing.key_dir + "/sk_ring.pai";
//The AES key used to encrypt the keyring. The AES key itself is encrypted with the hash of the password.
PaillierPrivateKeyRing.AES_key_file = PaillierPrivateKeyRing.key_dir + "/key.pai";
//The hash of the hash of the password. Is used for validating the supplied password.
PaillierPrivateKeyRing.pass_hash_file = PaillierPrivateKeyRing.key_dir + "/pass_hash.pai";

PaillierPrivateKeyRing.load_from_file = function (password)
{
	return new PaillierPrivateKeyRing(this.open_keyring(password));
};

PaillierPrivateKeyRing.open_keyring = function (password)
{
	const passHash = this.validate_password(password);
	
	if (passHash === null) { throw "Incorrect password, could not decrypt keyring."; }
	
	const keyring_key = this.load_keyring_key(passHash);
	const keyring_bytes = fs.readFileSync(this.keyring_file); //The first 16 bytes of the file is the IV.
	const iv = C.lib.WordArray.create(keyring_bytes.slice(0, 16));
	const keyring_enc = C.lib.WordArray.create(keyring_bytes.slice(16, keyring_bytes.length));
	const keyring = C.AES.decrypt(C.lib.CipherParams.create({ciphertext: keyring_enc}), C.enc.Hex.parse(keyring_key),
		{mode: C.mode.CBC, padding: C.pad.Pkcs7, iv: iv}).toString(C.enc.Utf8);
	
	return JSON.parse(keyring);
};

PaillierPrivateKeyRing.validate_password = function (password)
{
	const hash_triple = fs.readFileSync(this.pass_hash_file, 'utf-8').split(":");
	const iterations = hash_triple[0];
	const salt = C.enc.Hex.parse(hash_triple[1]);
	const stored_hash = hash_triple[2];
	const first_hash = C.PBKDF2(password, salt, {keySize: 256 / 32, iterations: iterations}).toString(C.enc.Hex);
	const second_hash = C.PBKDF2(first_hash, salt, {keySize: 256 / 32, iterations: iterations});
	
	return stored_hash == second_hash
		? first_hash //First hash is the AES key with which key.pai is encrypted.
		: null;
};

PaillierPrivateKeyRing.load_keyring_key = function (passHash)
{
	const key_bytes = fs.readFileSync(this.AES_key_file);
	const iv = C.lib.WordArray.create(key_bytes.slice(0, 16)); //The first 16 bytes of the file is the IV.
	const key_enc = C.lib.WordArray.create(key_bytes.slice(16, key_bytes.length));
	
	return C.AES.decrypt(C.lib.CipherParams.create({ciphertext: key_enc}), C.enc.Hex.parse(passHash),
		{mode: C.mode.CBC, padding: C.pad.Pkcs7, iv: iv}).toString(C.enc.Hex);
};

module.exports = PaillierPrivateKeyRing;