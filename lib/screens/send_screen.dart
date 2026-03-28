import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../providers/wallet_provider.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});
  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _toCtrl  = TextEditingController();
  final _amtCtrl = TextEditingController();
  double _gasFee = 0.0;
  bool   _loading     = false;
  bool   _estimating  = false;

  @override
  void initState() {
    super.initState();
    _estimateGas();
    _amtCtrl.addListener(_estimateGas);
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  Future<void> _estimateGas() async {
    setState(() => _estimating = true);
    final p = context.read<WalletProvider>();
    _gasFee = await p.estimateGasFee();
    if (mounted) setState(() => _estimating = false);
  }

  bool _validAddress(String addr) =>
      RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(addr);

  void _setMax() {
    final p = context.read<WalletProvider>();
    final max = (p.nativeBalance - _gasFee).clamp(0, double.infinity);
    _amtCtrl.text = max.toStringAsFixed(6);
  }

  Future<void> _send() async {
    final to  = _toCtrl.text.trim();
    final amt = double.tryParse(_amtCtrl.text.trim()) ?? 0;
    final p   = context.read<WalletProvider>();

    if (!_validAddress(to)) {
      _showError('收款地址格式无效');
      return;
    }
    if (amt <= 0) {
      _showError('请输入有效的转账金额');
      return;
    }
    if (amt > p.nativeBalance) {
      _showError('余额不足');
      return;
    }

    // 确认弹窗
    final confirmed = await _showConfirmDialog(to, amt, p);
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      final txHash = await p.sendTransaction(toAddress: to, amount: amt);
      if (!mounted) return;
      _showSuccessDialog(txHash, p);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  Future<bool> _showConfirmDialog(
      String to, double amt, WalletProvider p) async {
    final net  = p.network;
    final price = p.prices[net.symbol] ?? 0;
    final usd  = (amt * price).toStringAsFixed(2);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('确认转账',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _confirmRow('发送数量',
                      '$amt ${net.symbol}  (≈\$$usd)',
                      highlight: true),
                  _confirmRow('收款地址',
                      '${to.substring(0, 10)}...${to.substring(to.length - 6)}'),
                  _confirmRow('网络', net.name),
                  _confirmRow('手续费',
                      '>${_gasFee.toStringAsFixed(8)} ${net.symbol}'),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('֏f��',
                            style: TextStyle(color: AppColors.textSec)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('确认发送'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Widget _confirmRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSec)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: highlight ? AppColors.green : AppColors.textPri)),
        ],
      ),
    );
  }

  void _showSuccessDialog(String txHash, WalletProvider p) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('交易已发送！',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'TxHash: ${txHash.substring(0, 12)}...${txHash.substring(txHash.length - 8)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSec,
                    fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txHash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('交易哈希已复制')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('复制Hash',
                        style: TextStyle(color: AppColors.textSec,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(p.txUrl(txHash));
                      if (await canLaunchUrl(url)) launchUrl(url);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bnbYellow),
                    child: const Text('区块浏览器',
                        style: TextStyle(
                            fontSize: 13, color: Colors.black)),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('返回钱包'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p   = context.watch<WalletProvider>();
    final net = p.network;
    final bal = p.nativeBalance;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('转账'), backgroundColor: AppColors.bg),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 代币显示
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
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
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(net.symbol,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('余额: ${bal.toStringAsFixed(6)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSec)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 收款地址
              const Text('收款地址',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSec,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _toCtrl,
                decoration: InputDecoration(
                  hintText: '0x...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste_rounded,
                        color: AppColors.textSec, size: 20),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _toCtrl.text = data!.text!.trim();
                      }
                    },
                  ),
                ),
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 14),
              ),
              const SizedBox(height: 20),
              // 金额
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('金额',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSec,
                          fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: _setMax,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('MAX',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.0',
                  suffixText: net.symbol,
                  suffixStyle: const TextStyle(
                      color: AppColors.textSec, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              // 手续费信息
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('网络手续费',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSec)),
                        _estimating
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary))
                            : Text(
                                '~${_gasFee.toStringAsFixed(8)} ${net.symbol}',
                                style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('梉个发送切',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          (() {
                            final amt = double.tryParse(_amtCtrl.text) ?? 0;
                            final rcv = (amt - _gasFee).clamp(0, double.infinity);
                            return '${rcv.toStringAsFixed(6)} ${net.symbol}';
                          })(),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppColors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Text('确认转账'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
