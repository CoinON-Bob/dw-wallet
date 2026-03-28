import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/wallet_provider.dart';
import 'home_screen.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});
  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _mnCtrl  = TextEditingController();
  final _pkCtrl  = TextEditingController();
  bool _loading  = false;
  bool _obscurePk = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _mnCtrl.dispose();
    _pkCtrl.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final provider = context.read<WalletProvider>();
    setState(() => _loading = true);
    try {
      if (_tabs.index == 0) {
        final mnemonic = _mnCtrl.text.trim();
        if (mnemonic.isEmpty) throw Exception('请输入助记词');
        await provider.importFromMnemonic(mnemonic);
      } else {
        final pk = _pkCtrl.text.trim();
        if (pk.isEmpty) throw Exception('请输入私钥');
        await provider.importFromPrivateKey(pk);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('导入钱包')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab 切换
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSec,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '助记词'),
                    Tab(text: '私钥'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    // 助记词导入
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('输入 12 或 24 个助记词，单词间用空格分隔',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSec)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _mnCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'word1 word2 word3 ...',
                          ),
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.textSec, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '助记词由 BIP39 标准生成，支持所有兼容钱包',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSec),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 私钥导入
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('输入 64 位十六进制私钥（可带 0x 前缀）',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSec)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pkCtrl,
                          obscureText: _obscurePk,
                          decoration: InputDecoration(
                            hintText: '0x...',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePk
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.textSec,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePk = !_obscurePk),
                            ),
                          ),
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.red.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.security_rounded,
                                  color: AppColors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '私钥加密存储在本地。请勿在公共网络下导入。',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSec),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _import,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Text('导入钱包'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
