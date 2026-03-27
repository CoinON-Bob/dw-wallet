import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../config/networks.dart';
import '../models/wallet_model.dart';
import 'wallet_service.dart';

const _erc20Abi = '''[
  {"constant":true,"inputs":[{"name":"_owner","type":"address"}],
   "name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],
   "type":"function"},
  {"constant":true,"inputs":[],"name":"decimals",
   "outputs":[{"name":"","type":"uint8"}],"type":"function"}
]''';

class Web3Service {
  Web3Client? _client;
  NetworkConfig _network = Networks.bsc;

  NetworkConfig get currentNetwork => _network;

  void setNetwork(NetworkConfig net) {
    _network = net;
    _client?.dispose();
    _client = Web3Client(net.rpcUrl, http.Client());
  }

  Web3Client get client {
    _client ??= Web3Client(_network.rpcUrl, http.Client());
    return _client!;
  }

  void dispose() {
    _client?.dispose();
    _client = null;
  }

  Future<double> getNativeBalance(String address) async {
    try {
      final addr    = EthereumAddress.fromHex(address);
      final balance = await client.getEtherBalance(addr);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTokenBalance(
      String walletAddress, String contractAddress, int decimals) async {
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );
      final balanceOf = contract.function('balanceOf');
      final result    = await client.call(
        contract: contract,
        function: balanceOf,
        params:   [EthereumAddress.fromHex(walletAddress)],
      );
      final raw = (result.first as BigInt);
      return raw / BigInt.from(10).pow(decimals);
    } catch (e) {
      return 0.0;
    }
  }

  Future<EtherAmount> getGasPrice() async {
    try {
      return await client.getGasPrice();
    } catch (_) {
      return EtherAmount.fromInt(EtherUnit.gwei, 5);
    }
  }

  Future<BigInt> estimateGas({
    required String from,
    required String to,
    required BigInt value,
  }) async {
    try {
      return await client.estimateGas(
        sender: EthereumAddress.fromHex(from),
        to:     EthereumAddress.fromHex(to),
        value:  EtherAmount.inWei(value),
      );
    } catch (_) {
      return BigInt.from(21000);
    }
  }

  Future<String> sendNative({
    required WalletModel wallet,
    required String toAddress,
    required double amount,
  }) async {
    final creds    = WalletService.credentialsFromWallet(wallet);
    final gasPrice = await getGasPrice();
    final weiAmount = EtherAmount.fromBigInt(
      EtherUnit.wei,
      BigInt.from((amount * 1e18).toInt()),
    );

    final txHash = await client.sendTransaction(
      creds,
      Transaction(
        to:       EthereumAddress.fromHex(toAddress),
        value:    weiAmount,
        gasPrice: gasPrice,
        maxGas:   21000,
      ),
      chainId: _network.chainId,
    );
    return txHash;
  }

  Future<int> getTransactionCount(String address) async {
    try {
      return await client.getTransactionCount(
        EthereumAddress.fromHex(address),
      );
    } catch (_) {
      return 0;
    }
  }

  static Future<Map<String, double>> fetchPrices() async {
    try {
      final uri = Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price'
          '?ids=binancecoin,ethereum,matic-network&vs_currencies=usd');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return {
          'BNB':  (data['binancecoin']?['usd'] ?? 0).toDouble(),
          'ETH':  (data['ethereum']?['usd'] ?? 0).toDouble(),
          'POL':  (data['matic-network']?['usd'] ?? 0).toDouble(),
          'MATIC':(data['matic-network']?['usd'] ?? 0).toDouble(),
          'USDT': 1.0,
          'BUSD': 1.0,
        };
      }
    } catch (_) {}
    return {};
  }

  String txUrl(String txHash) => '${_network.explorer}/tx/$txHash';
  String addressUrl(String addr) => '${_network.explorer}/address/$addr';
}
