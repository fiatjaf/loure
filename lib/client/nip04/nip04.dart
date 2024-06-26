import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:convert/convert.dart";
import "package:pointycastle/export.dart";

class NIP04 {
  static var secp256k1 = ECDomainParameters("secp256k1");

  static ECDHBasicAgreement getAgreement(final String sk) {
    final skD0 = BigInt.parse(sk, radix: 16);
    final privateKey = ECPrivateKey(skD0, secp256k1);

    final agreement = ECDHBasicAgreement();
    agreement.init(privateKey);

    return agreement;
  }

  static String encrypt(final String message,
      final ECDHBasicAgreement agreement, final String pk) {
    final pubkey = getPubKey(pk);
    final agreementD0 = agreement.calculateAgreement(pubkey);
    final enctyptKey = agreementD0.toRadixString(16).padLeft(64, "0");

    final random = Random.secure();
    final ivData = Uint8List.fromList(
        List<int>.generate(16, (final i) => random.nextInt(256)));
    // var iv = "UeAMaJl5Hj6IZcot7zLfmQ==";
    // var ivData = base64.decode(iv);

    final cipherCbc =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));
    final paramsCbc = PaddedBlockCipherParameters(
        ParametersWithIV(
            KeyParameter(Uint8List.fromList(hex.decode(enctyptKey))), ivData),
        null);
    cipherCbc.init(true, paramsCbc);

    // print(cipherCbc.algorithmName);

    final result = cipherCbc.process(Uint8List.fromList(utf8.encode(message)));

    return "${base64.encode(result)}?iv=${base64.encode(ivData)}";
  }

  static String decrypt(
      String message, final ECDHBasicAgreement agreement, final String pk) {
    final strs = message.split("?iv=");
    if (strs.length != 2) {
      return "";
    }
    message = strs[0];
    final iv = strs[1];
    final ivData = base64.decode(iv);

    final pubkey = getPubKey(pk);
    final agreementD0 = agreement.calculateAgreement(pubkey);
    final encryptKey = agreementD0.toRadixString(16).padLeft(64, "0");

    // var encrypter = Encrypter(AES(
    //     Key(Uint8List.fromList(hex.decode(encryptKey))),
    //     mode: AESMode.cbc));
    // return encrypter.decrypt(Encrypted.from64(message), iv: IV.fromBase64(iv));

    final cipherCbc =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));
    final paramsCbc = PaddedBlockCipherParameters(
        ParametersWithIV(
            KeyParameter(Uint8List.fromList(hex.decode(encryptKey))), ivData),
        null);
    cipherCbc.init(false, paramsCbc);

    final result = cipherCbc.process(base64.decode(message));

    return utf8.decode(result);
  }

  static ECPublicKey getPubKey(final String pk) {
    // BigInt x = BigInt.parse(pk, radix: 16);
    final BigInt x =
        BigInt.parse(hex.encode(hex.decode(pk.padLeft(64, "0"))), radix: 16);
    BigInt? y;
    try {
      y = liftX(x);
    } on Error {
      print("error in handle pubkey");
    }
    final ECPoint endPoint = secp256k1.curve.createPoint(x, y!);
    return ECPublicKey(endPoint, secp256k1);
  }

  static var curveP = BigInt.parse(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",
      radix: 16);

  // helper methods:
  // liftX returns Y for this X
  static BigInt liftX(final BigInt x) {
    if (x >= curveP) {
      throw Error();
    }
    final ySq = (x.modPow(BigInt.from(3), curveP) + BigInt.from(7)) % curveP;
    final y = ySq.modPow((curveP + BigInt.one) ~/ BigInt.from(4), curveP);
    if (y.modPow(BigInt.two, curveP) != ySq) {
      throw Error();
    }
    return y % BigInt.two == BigInt.zero /* even */ ? y : curveP - y;
  }

  static String generate16RandomHexChars() {
    final random = Random.secure();
    final randomBytes =
        List<int>.generate(16, (final i) => random.nextInt(256));
    return hex.encode(randomBytes);
  }
}
