import 'package:flutter/material.dart';
import '../config/networks.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../services/web3_service.dart';

enum WalletState { uninitialized, loading, ready, error }

class WalletProvider extends ChangeNotifier {
  final Web3Service _web3 = Web3Service();

  WalletModel? _wallet;
  WalletState   _state  = WalletState.uninitialized;
  NetworkConfig _network = Networks.bsc;

  double          _nativeBalance = 0.0;
  Map<String, double> _prices   = {};
  bool            _loadingBal   = false;
  String?         _error;

  // ── Getters ───────────────────────────────────
  WalletModel?    get wallet       => _wallet;
  WalletState     get state        => _state;
  NetworkConfig   get network      => _network;
  double          get nativeBalance => _nativeBalance;
  Map<String, double> get prices   => _prices;
  bool            get isLoading    => _loadingBal;
  String?         get error        => _error;
  bool            get hasWallet    => _wallet != null;

  double get nativeUsd {
    final p = _prices[_network.symbol] ?? 0;
    return _nativeBalance * p;
  }

  // ── 初始化（app 启动时调用） ────────────────────
  Future<void> init() async {
    _state = WalletState.loading;
    notifyListeners();
    try {
      final saved = await WalletService.loadWallet();
      if (saved != null) {
        _wallet = saved;
        _web3.setNetwork(_network);
        _state = WalletState.ready;
        notifyListeners();
        await refreshAll();
      } else {
        _state = WalletState.uninitialized;
        notifyListeners();
      }
    } catch (e) {
      _state = WalletState.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── 创建钱包 ──────────────────────────────────
  Future<void> createWallet(String mnemonic) async {
    _state = WalletState.loading;
    notifyListeners();
    final w = WalletService.createWallet(mnemonic);
    await WalletService.saveWallet(w);
    _wallet = w;
    _web3.setNetwork(_network);
    _state = WalletState.ready;
    notifyListeners();
    await refreshAll();
  }

  // ── 导入助记词 ────────────────────────────────
  Future<void> importFromMnemonic(String mnemonic) async {
    if (!WalletService.validateMnemonic(mnemonic)) {
      throw Exception('助记词格式无效');
    }
    _state = WalletState.loading;
    notifyListeners();
    final w = WalletService.createWallet(mnemonic);
    await WalletService.saveWallet(w);
    _wallet = w;
    _web3.setNetwork(_network);
    _state = WalletState.ready;
    notifyListeners();
    await refreshAll();
  }

  // ── 导入私钥 ──────────────────────────────────
  Future<void> importFromPrivateKey(String privateKey) async {
    _state = WalletState.loading;
    notifyListeners();
    try {
      final w = WalletService.importFromPrivateKey(privateKey);
      await WalletService.saveWallet(w);
      _wallet = w;
      _web3.setNetwork(_network);
      _state = WalletState.ready;
      notifyListeners();
      await refreshAll();
    } catch (e) {
      _state = WalletState.error;
      _error = '私钥格式无效';
      notifyListeners();
      rethrow;
    }
  }

  // ── 切换网络 ──────────────────────────────────
  Future<void> switchNetwork(NetworkConfig net) async {
    _network = net;
    _web3.setNetwork(net);
    _nativeBalance = 0.0;
    notifyListeners();
    await refreshBalance();
  }

  // ── 刷新余额 ──────────────────────────────────
  Future<void> refreshBalance() async {
    if (_wallet == null) return;
    _loadingBal = true;
    notifyListeners();
    try {
      _nativeBalance = await _web3.getNativeBalance(_wallet!.address);
    } catch (_) {}
    _loadingBal = false;
    notifyListeners();
  }

  // ── 获取价格 ──────────────────────────────────
  Future<void> refreshPrices() async {
    _prices = await Web3Service.fetchPrices();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([refreshBalance(), refreshPrices()]);
  }

  // ── 发送交易 ──────────────────────────────────
  Future<String> sendTransaction({
    required String toAddress,
    required double amount,
  }) async {
    if (_wallet == null) throw Exception('钱包未初始化');
    final txHash = await _web3.sendNative(
      wallet:    _wallet!,
      toAddress: toAddress,
      amount:    amount,
    );
    await refreshBalance();
    return txHash;
  }

  // ── Gas 估算 ──────────────────────────────────
  Future<double> estimateGasFee() async {
    final gasPrice = await _web3.getGasPrice();
    final gasFee   = gasPrice.getValueInUnit(EtherUnit.ether) * 21000;
    return gasFee;
  }

  // ── 退出钱包 ──────────────────────────────────
  Future<void> logout() async {
    await WalletService.deleteWallet();
    _wallet         = null;
    _nativeBalance  = 0.0;
    _state          = WalletState.uninitialized;
    notifyListeners();
  }

  // ── Explorer URL ──────────────────────────────
  String txUrl(String hash) => _web3.txUrl(hash);
  String addressUrl()       => _web3.addressUrl(_wallet?.address ?? '');
}
