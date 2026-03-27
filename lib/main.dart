import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/wallet_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:       Colors.transparent,
    statusBarBrightness:  Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const DWWalletApp());
}

class DWWalletApp extends StatelessWidget {
  const DWWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletProvider()..init(),
      child: MaterialApp(
        title: 'DW Wallet',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
