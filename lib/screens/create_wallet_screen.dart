import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/wallet_provider.dart';
import '../services/wallet_service.dart';
import 'home_screen.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});
  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  late String _mnemonic;
  bool _backed = false;
  bool _loading = false;
  int  _step = 0;

  @override
  void initState() {
    super.initState();
    _mnemonic = WalletService.generateMnemonic();
  }

  void _refresh() {
    setState(() => _mnemonic = WalletService.generateMnemonic());
  }

  Future<void> _createWallet() async {
    setState(() => _loading = true);
    try {
      await context.read<WalletProvider>().createWallet(_mnemonic);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建失败: $e'), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _mnemonic.split(' ');
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('创建新钱包'), backgroundColor: AppColors.bg),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
                ),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.yellow, size: 22),
                  SizedBox(width: 10),
                  Expanded(child: Text('该是您全孹指令，丢失后无法找回钱包资产！',
                    style: TextStyle(fontSize: 13, color: AppColors.textSec, height: 1.5))),
                ]),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 2.6,
                  crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: words.length,
                itemBuilder: (_, i) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.card2, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${i + 1}.', style: const TextStyle(fontSize: 11, color: AppColors.textSec)),
                    const SizedBox(width: 4),
                    Text(words[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: _mnemonic));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('复制助记词已复选料'), duration: Duration(seconds: 2))); },
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                  label: const Text('交创助��词', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSec),
                  label: const Text('要新生成', style: TextStyle(color: AppColors.textSec)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
              ]),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => setState(() => _backed = !_backed),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _backed ? AppColors.green : AppColors.border)),
                  child: Row(children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 200),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: _backed ? AppColors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _backed ? AppColors.green : AppColors.textSec, width: 1.5)),
                      child: _backed ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('我已安全备份助记词，丢失无法找回钱包',
                      style: TextStyle(fontSize: 14, height: 1.4))),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _backed && !_loading ? _createWallet : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _backed ? AppColors.primary : AppColors.card2,
                  minimumSize: const Size(double.infinity, 54)),
                child: _loading ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('已备份，创建钱包'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
