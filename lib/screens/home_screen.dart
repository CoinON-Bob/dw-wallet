import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'wallet_tab.dart';
import 'dapp_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _pages = [
    WalletTab(),
    DAppScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: Color(0xDD0B0F1E),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon:          Icon(Icons.account_balance_wallet_outlined),
              selectedIcon:  Icon(Icons.account_balance_wallet_rounded,
                              color: AppColors.primary),
              label: '钱包',
            ),
            NavigationDestination(
              icon:         Icon(Icons.language_outlined),
              selectedIcon: Icon(Icons.language_rounded,
                              color: AppColors.primary),
              label: '发现',
            ),
            NavigationDestination(
              icon:         Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded,
                              color: AppColors.primary),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
