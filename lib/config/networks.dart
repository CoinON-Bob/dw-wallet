import 'package:flutter/material.dart';

class NetworkConfig {
  final String key;
  final String name;
  final String symbol;
  final String rpcUrl;
  final String rpcUrlBackup;
  final int chainId;
  final String explorer;
  final Color color;
  final String icon;
  final int decimals;
  const NetworkConfig({required this.key,required this.name,required this.symbol,required this.rpcUrl,this.rpcUrlBackup='',required this.chainId,required this.explorer,required this.color,required this.icon,this.decimals=18,});
}
class Networks {static const bsc=NetworkConfig(key:'bsc',name:'BNB Smart Chain',symbol:'BNB',rpcUrl:'https://bsc-dataseed.binance.org/',chainId:56,explorer:'https://bscscan.com',color:Color(0xFFF3BA2F),icon:'B');}
