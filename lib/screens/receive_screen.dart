import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_theme.dart';
import '../providers/wallet_provider.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p      = context.watch<WalletProvider>();
    final wallet = p.wallet;
    final net    = p.network;
    if (wallet == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('收款'),
        backgroundColor: AppColors.bg,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: net.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(net.symbol,
                  style: TextStyle(
                      color: net.color,
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                '分享以下地址接收 ${net.symbol} 及 BEP-20 代币',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSec, height: 1.5),
              ),
              const SizedBox(height: 28),
              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 30, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: wallet.address,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // 地址显示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text('钱包地址',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSec)),
                    const SizedBox(height: 8),
                    Text(
                      wallet.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, fontFamily: 'monospace',
                          height: 1.6, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 复制按钮
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: wallet.address));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅  钱包地址已复制'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('复制地址'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.yellow.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.yellow, size: 16),
                    SizedBow(width: 8),
                    Expanded(
                      child: Text(
                        '仅发送 BNB 及 BEP-20 代币到此地址，发送其他链资产可能导致永久丢失',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSec,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
