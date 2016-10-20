const fs = require('fs');

var PaillierPublicKeyRing = function (key_ring_json)
{
	this.keys = key_ring_json;
};

PaillierPublicKeyRing.key_dir = "./keys";
PaillierPublicKeyRing.keyring_file = PaillierPublicKeyRing.key_dir + "/pk_ring.pai";

PaillierPublicKeyRing.load_from_file = function ()
{
	return new PaillierPublicKeyRing(JSON.parse(fs.readFileSync(this.keyring_file, 'utf-8')))
};
module.exports = PaillierPublicKeyRing;