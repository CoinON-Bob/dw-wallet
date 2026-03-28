import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/networks.dart';
import '../providers/wallet_provider.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});
  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().refreshAll();
    });
  }

  void _showNetworkSheet(BuildContext ctx, WalletProvider p) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('选择网络',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...Networks.all.map((net) => _networkTile(net, p, ctx)),
          ],
        ),
      ),
    );
  }

  Widget _networkTile(NetworkConfig net, WalletProvider p, BuildContext ctx) {
    final selected = p.network.key == net.key;
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        p.switchNetwork(net);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: net.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(net.icon,
                    style: TextStyle(
                        color: net.color,
                        fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(net.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('${net.symbol}  ·  Chain ${net.chainId}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSec)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WalletProvider>();
    if (!p.hasWallet) return const SizedBox();
    final wallet  = p.wallet!;
    final net     = p.network;
    final price   = p.prices[net.symbol] ?? 0.0;
    final usd     = (p.nativeBalance * price);
    final balFmt  = p.nativeBalance.toStringAsFixed(6);
    final usdFmt  = usd.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: () => p.refreshAll(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.card.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 网络选择器
                    GestureDetector(
                      onTap: () => _showNetworkSheet(context, p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                  color: net.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(net.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: AppColors.textSec),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 地址行
                    Row(
                      children: [
                        const Text('账户 1',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSec)),
                        const SizedBox(width: 8),
                        Text(wallet.shortAddress,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSec,
                                fontFamily: 'monospace')),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('地址已复制'),
                                  duration: Duration(seconds: 2)),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.card2,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('复制',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.textSec)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 余额
                    if (p.isLoading)
                      const SizedBox(
                        height: 56,
                        child: Center(
                          child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: balFmt,
                                  style: const TextStyle(
                                    fontSize: 38, fontWeight: FontWeight.w800,
                                    color: Colors.white, letterSpacing: -1,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ${net.symbol}',
                                  style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600,
                                    color: AppColors.textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('≈ \$$usdFmt USD',
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textSec)),
                        ],
                      ),
                    const SizedBox(height: 28),
                    // 操作按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionBtn(
                          context,
                          icon: Icons.arrow_upward_rounded,
                          label: '转账',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const SendScreen())),
                        ),
                        _actionBtn(
                          context,
                          icon: Icons.arrow_downward_rounded,
                          label: '收款',
                          color: AppColors.green,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ReceiveScreen())),
                        ),
                        _actionBtn(
                          context,
                          icon: Icons.swap_horiz_rounded,
                          label: '兑换',
                          color: const Color(0xFFF59E0B),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('兑换功能即将上线')),
                          ),
                        ),
                        _actionBtn(
                          context,
                          icon: Icons.refresh_rounded,
                          label: '刷新',
                          color: AppColors.textSec,
                          onTap: () => p.refreshAll(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            // ── 资产列表 ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('我的资产',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSec,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    // 原生代币
                    _assetTile(
                      icon: net.icon,
                      iconColor: net.color,
                      name: net.symbol,
                      subname: net.name,
                      balance: balFmt,
                      usd: '\$$usdFmt',
                    ),
                    // BSC 代币（仅在 BSC 网络显示）
                    if (net.key == 'bsc' || net.key == 'bsc_testnet')
                      ...BscTokens.tokens.map((t) => _assetTile(
                        icon: t['icon'] as String,
                        iconColor: AppColors.bnbYellow,
                        name: t['symbol'] as String,
                        subname: t['name'] as String,
                        balance: '--',
                        usd: '--',
                        isToken: true,
                      )),
                    const SizedBox(height: 16),
                    // 添加代币按钮
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary, size: 18),
                      label: const Text('添加代币',
                          style: TextStyle(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: const BorderSide(
                            color: AppColors.border, style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSec)),
        ],
      ),
    );
  }

  Widget _assetTile({
    required String icon,
    required Color iconColor,
    required String name,
    required String subname,
    required String balance,
    required String usd,
    bool isToken = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(subname,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSec)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text(isToken ? 'BEP-20' : usd,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSec)),
            ],
          ),
        ],
      ),
    );
  }
}
