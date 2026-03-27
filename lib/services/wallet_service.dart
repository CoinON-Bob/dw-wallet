import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import '../models/wallet_model.dart';

class WalletService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyPrivateKey = 'dw_private_key';
  static const _keyMnemonic   = 'dw_mnemonic';

  static String generateMnemonic() => bip39.generateMnemonic();

  static bool validateMnemonic(String mnemonic) =>
      bip39.validateMnemonic(mnemonic.trim());

  static EthPrivateKey deriveFromMnemonic(String mnemonic, {int index = 0}) {
    final Uint8List seed = bip39.mnemonicToSeed(mnemonic.trim());
    final root  = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/$index");
    final pkHex = hex.encode(child.privateKey!);
    return EthPrivateKey.fromHex(pkHex);
  }

  static WalletModel createWallet(String mnemonic) {
    final creds   = deriveFromMnemonic(mnemonic);
    final address = creds.address.hex;
    return WalletModel(
      address:    address,
      privateKey: '0x${hex.encode(creds.privateKey)}',
      mnemonic:   mnemonic,
    );
  }

  static WalletModel importFromPrivateKey(String privateKey) {
    final pk = privateKey.startsWith('0x') ? privateKey : '0x$privateKey';
    final creds   = EthPrivateKey.fromHex(pk);
    final address = creds.address.hex;
    return WalletModel(
      address:    address,
      privateKey: pk,
      mnemonic:   null,
    );
  }

  static Future<void> saveWallet(WalletModel wallet) async {
    await _storage.write(key: _keyPrivateKey, value: wallet.privateKey);
    if (wallet.mnemonic != null) {
      await _storage.write(key: _keyMnemonic, value: wallet.mnemonic!);
    }
  }

  static Future<WalletModel?> loadWallet() async {
    final pk = await _storage.read(key: _keyPrivateKey);
    if (pk == null) return null;
    final mnemonic = await _storage.read(key: _keyMnemonic);
    final creds    = EthPrivateKey.fromHex(pk);
    return WalletModel(
      address:    creds.address.hex,
      privateKey: pk,
      mnemonic:   mnemonic,
    );
  }

  static Future<void> deleteWallet() async {
    await _storage.delete(key: _keyPrivateKey);
    await _storage.delete(key: _keyMnemonic);
  }

  static Future<bool> hasWallet() async {
    final pk = await _storage.read(key: _keyPrivateKey);
    return pk != null;
  }

  static EthPrivateKey credentialsFromWallet(WalletModel wallet) =>
      EthPrivateKey.fromHex(wallet.privateKey);
}
