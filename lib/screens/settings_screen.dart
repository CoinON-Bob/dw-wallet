import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../providers/wallet_provider.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WalletProvider>();
    final wallet = p.wallet;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 24),
            const Text('设置',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),

            // ── 钱包信息卡 ──────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    const Color(0xFFA855F7).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_circle_rounded,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('账户 1',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (wallet != null) ...[
                          const SizedBox(height: 4),
                          Text(wallet.shortAddress,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textSec,
                                  fontFamily: 'monospace')),
                        ],
                      ],
                    ),
                  ),
                  if (wallet != null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          color: AppColors.primary, size: 20),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: wallet.address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('地址已复制'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 钱包安全 ───────────────────────────
            _sectionTitle('钱包安全'),
            _settingsTile(
              icon: Icons.lock_outline_rounded,
              iconBg: AppColors.yellow.withOpacity(0.15),
              iconColor: AppColors.yellow,
              title: '查看助记词',
              subtitle: '备份您的钱包恢复短语',
              onTap: () => _showSecret(context, p, isMnemonic: true),
            ),
            _settingsTile(
              icon: Icons.vpn_key_rounded,
              iconBg: AppColors.primary.withOpacity(0.15),
              iconColor: AppColors.primary,
              title: '导出私钥',
              subtitle: '查看当前账户私钥',
              onTap: () => _showSecret(context, p, isMnemonic: false),
            ),

            // ── 网络 ──────────────────────────────
            _sectionTitle('网络'),
            _settingsTile(
              icon: Icons.language_rounded,
              iconBg: AppColors.green.withOpacity(0.15),
              iconColor: AppColors.green,
              title: '当前网络',
              subtitle: p.network.name,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.network.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.network.symbol,
                    style: TextStyle(
                        color: p.network.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
              onTap: null,
            ),
            _settingsTile(
              icon: Icons.open_in_browser_rounded,
              iconBg: AppColors.bnbYellow.withOpacity(0.15),
              iconColor: AppColors.bnbYellow,
              title: '在 BscScan 查看',
              subtitle: '在浏览器中查看账户详情',
              onTap: wallet == null ? null : () async {
                final url = Uri.parse(p.addressUrl());
                if (await canLaunchUrl(url)) launchUrl(url);
              },
            ),

            // ── 关于 ──────────────────────────────
            _sectionTitle('关于'),
            _settingsTile(
              icon: Icons.info_outline_rounded,
              iconBg: AppColors.card2,
              iconColor: AppColors.textSec,
              title: 'DW Wallet',
              subtitle: '版本 1.0.0',
              onTap: null,
            ),

            // ── 退出 ──────────────────────────────
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _logout(context, p),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.red.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                    SizedBox(width: 10),
                    Text('退出钱包',
                        style: TextStyle(
                            color: AppColors.red,
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
    child: Text(title.toUpperCase(),
        style: const TextStyle(
            fontSize: 12, color: AppColors.textSec,
            fontWeight: FontWeight.w600, letterSpacing: 0.8)),
  );

  Widget _settingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSec)),
                    ],
                  ),
                ),
                trailing ??
                    (onTap != null
                        ? const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSec, size: 20)
                        : const SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSecret(BuildContext context, WalletProvider p,
      {required bool isMnemonic}) {
    final wallet = p.wallet;
    if (wallet == null) return;
    if (isMnemonic && wallet.mnemonic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('此钱包通过私钥导入，无助记词')),
      );
      return;
    }
    final content = isMnemonic ? wallet.mnemonic! : wallet.privateKey;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isMnemonic ? '查看助记词' : '导出私钥',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.yellow.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.yellow, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请确保周围无人，切勿截图或泄露',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSec),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  content,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 13,
                      height: 1.7),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text('复制',
                        style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('关闭'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WalletProvider p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('退出钱包'),
        content: const Text(
          '确认退出？本地密钥将被清除，请确保已备份助记词或私钥。',
          style: TextStyle(color: AppColors.textSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await p.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
      }
    }
  }
}
