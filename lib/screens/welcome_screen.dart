import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'create_wallet_screen.dart';
import 'import_wallet_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFA855F7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.45),
                      blurRadius: 40, offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: 28),
              const Text('欢迎使用 DW Wallet',
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
              const SizedBox(height: 12),
              const Text(
                '安全、快速的去中心化钱包\n主链：BNB Smart Chain（BSC）',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, color: AppColors.textSec, height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              // 链标志
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chainChip('BNB Chain', AppColors.bnbYellow),
                  const SizedBox(width: 10),
                  _chainChip('ETH', AppColors.ethBlue),
                  const SizedBox(width: 10),
                  _chainChip('Polygon', AppColors.polyPurple),
                  const SizedBox(width: 10),
                  _chainChip('更多', AppColors.textSec),
                ],
              ),
              const Spacer(flex: 3),
              // 创建钱包按钮
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreateWalletScreen())),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('创建新钱包'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
              const SizedBox(height: 14),
              // 导入钱包按钮
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ImportWalletScreen())),
                icon: const Icon(Icons.download_rounded, size: 20, color: AppColors.primary),
                label: const Text('导入已有钱包',
                    style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '⚠️  私钥仅保存在本地设备，请做好备份',
                style: TextStyle(fontSize: 12, color: AppColors.textSec),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chainChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
