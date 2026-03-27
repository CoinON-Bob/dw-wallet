class WalletModel {
  final String address;
  final String privateKey;
  final String? mnemonic;
  final String name;
  WalletModel({required this.address,required this.privateKey,this.mnemonic,this.name='账户钱包 1',});
  String get shortAddress => '${address.substring(0,6)}...${address.substring(address.length-4)}';
}
class TokenBalance {final String symbol;final String name;final String balance;final double balanceDouble;final double usdValue;final String icon;final String? contractAddress;final String networkKey;const TokenBalance({required this.symbol,required this.name,required this.balance,required this.balanceDouble,required this.usdValue,required this.icon,this.contractAddress,required this.networkKey,});}
