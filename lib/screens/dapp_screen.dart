import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_theme.dart';

class _DApp {
  final String name;
  final String url;
  final String icon;
  final Color  color;
  final String category;
  const _DApp({
    required this.name, required this.url, required this.icon,
    required this.color, required this.category,
  });
}

const _dapps = [
  _DApp(name: 'PancakeSwap', url: 'https://pancakeswap.finance/swap',
      icon: '🥞', color: Color(0xFFFFB800), category: 'DeFi'),
  _DApp(name: '1inch', url: 'https://app.1inch.io/#/56',
      icon: '🔮', color: Color(0xFF2471E1), category: 'DEX'),
  _DApp(name: 'Venus', url: 'https://app.venus.io/',
      icon: '♀', color: Color(0xFFB6509E), category: '借贷'),
  _DApp(name: 'Alpaca', url: 'https://app.alpacafinance.org/',
      icon: '🦙', color: Color(0xFF00C08B), category: '杠杆'),
  _DApp(name: 'BscScan', url: 'https://bscscan.com',
      icon: '🔍', color: Color(0xFFF0B90B), category: '浏览器'),
  _DApp(name: 'Biswap', url: 'https://biswap.org/swap',
      icon: '⚡', color: Color(0xFF00A3FF), category: 'DEX'),
  _DApp(name: 'ApeSwap', url: 'https://apeswap.finance/swap',
      icon: '🦍', color: Color(0xFFF7A93C), category: 'DEX'),
  _DApp(name: 'NFT Key', url: 'https://nftkey.app',
      icon: '🎨', color: Color(0xFF8B5CF6), category: 'NFT'),
];

class DAppScreen extends StatefulWidget {
  const DAppScreen({super.key});
  @override
  State<DAppScreen> createState() => _DAppScreenState();
}

class _DAppScreenState extends State<DAppScreen> {
  WebViewController? _controller;
  final _urlCtrl = TextEditingController();
  bool _browsing = false;
  bool _loading  = false;
  String _currentUrl = '';
  double _progress = 0;

  void _openDapp(String url) {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (u) => setState(() {
          _loading = true; _currentUrl = u;
          _urlCtrl.text = u;
        }),
        onPageFinished: (_) => setState(() => _loading = false),
        onProgress: (p) => setState(() => _progress = p / 100),
        onWebResourceError: (e) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = ctrl;
      _browsing   = true;
      _currentUrl = url;
      _urlCtrl.text = url;
    });
  }

  void _navigate() {
    var url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    _openDapp(url);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── 地址栏 ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (_browsing)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textSec),
                      onPressed: () async {
                        if (await _controller!.canGoBack()) {
                          _controller!.goBack();
                        } else {
                          setState(() { _browsing = false; _controller = null; });
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _urlCtrl,
                      onSubmitted: (_) => _navigate(),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: '搜索或输入网址',
                        prefixIcon: _loading
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.bnbYellow,
                                    value: _progress,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search_rounded,
                                color: AppColors.textSec, size: 18),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _navigate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bnbYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('前往',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            // ── 内容区 ───────────────────────────────
            Expanded(
              child: _browsing && _controller != null
                  ? WebViewWidget(controller: _controller!)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text('BSC 热门 DApp',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                          // DEX / DeFi
                          _categorySection('DeFi & DEX'),
                          _dappGrid(_dapps
                              .where((d) =>
                                  d.category == 'DeFi' ||
                                  d.category == 'DEX')
                              .toList()),
                          _categorySection('借贷 & 杠杆'),
                          _dappGrid(_dapps
                              .where((d) =>
                                  d.category == '借贷' ||
                                  d.category == '杠杆')
                              .toList()),
                          _categorySection('工具 & NFT'),
                          _dappGrid(_dapps
                              .where((d) =>
                                  d.category == '浏览器' ||
                                  d.category == 'NFT')
                              .toList()),
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

  Widget _categorySection(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Text(title,
        style: const TextStyle(
            fontSize: 13, color: AppColors.textSec,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5)),
  );

  Widget _dappGrid(List<_DApp> apps) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final d = apps[i];
        return GestureDetector(
          onTap: () => _openDapp(d.url),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: d.color.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(d.icon,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 6),
              Text(d.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSec)),
            ],
          ),
        );
      },
    ),
  );
}
