# DW Wallet - Flutter 去中心化钱包

主链：BNB Smart Chain (BSC)，支持多链扩展

## 功能特性

- ✅ 创建钱包（BIP39 助记词，BIP44 派生路径）
- ✅ 导入钱包（助记词 / 私钥）
- ✅ 多链支持（BSC、ETH、Polygon、Arbitrum、opBNB）
- ✅ 查看 BNB 余额 + 实时美元价格
- ✅ 转账（发送原生代币，上链广播）
- ✅ 收款（QR 码 + 复制地址）
- ✅ 内置 DApp 浏览器（支持 PancakeSwap 等 BSC DApp）
- ✅ 私钥安全存储（flutter_secure_storage 加密）
- ✅ 导出助记词 / 私钥
- ✅ 深色主题 UI

## 快速开始

### 前置条件
- Flutter SDK >= 3.1.0
- Dart SDK >= 3.1.0
- Android Studio / VS Code
- Android 设备或模拟器（API 21+）

### 安装运行

```bash
# 1. 进入项目目录
cd dw_wallet

# 2. 安装依赖
flutter pub get

# 3. 运行
flutter run

# 4. 打包 APK
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart                    # 入口
├── config/
│   ├── app_theme.dart          # 颜色主题
│   └── networks.dart           # 网络配置（BSC/ETH/Polygon...）
├── models/
│   └── wallet_model.dart       # 数据模型
├── services/
│   ├── wallet_service.dart     # BIP39/BIP44 钱包操作
│   └── web3_service.dart       # web3dart 区块链调用
├── providers/
│   └── wallet_provider.dart    # 全局状态管理（Provider）
└── screens/
    ├── splash_screen.dart      # 启动页
    ├── welcome_screen.dart     # 欢迎页
    ├── create_wallet_screen.dart # 创建钱包
    ├── import_wallet_screen.dart # 导入钱包
    ├── home_screen.dart        # 主页（底部导航）
    ├── wallet_tab.dart         # 钱包余额页
    ├── send_screen.dart        # 转账
    ├── receive_screen.dart     # 收款 QR
    ├── dapp_screen.dart        # DApp 浏览器
    └── settings_screen.dart    # 设置
```

## 技术栈

| 依赖 | 用途 |
|------|------|
| web3dart | EVM 区块链交互 |
| bip39 | BIP39 助记词生成/验证 |
| bip32 | HD 钱包密钥派生 |
| flutter_secure_storage | 私钥加密存储 |
| qr_flutter | 收款二维码生成 |
| webview_flutter | DApp 内置浏览器 |
| provider | 状态管理 |
| http / dio | 网络请求 |

## BSC 网络配置

| 参数 | 值 |
|------|----|
| 网络名称 | BNB Smart Chain |
| RPC URL | https://bsc-dataseed.binance.org/ |
| Chain ID | 56 |
| 符号 | BNB |
| 区块浏览器 | https://bscscan.com |

## ⚠️ 安全提示

- 私钥使用 Android Keystore / iOS Secure Enclave 加密存储
- 建议在生产版本中添加生物识别解锁
- 切勿将私钥或助记词传输到任何服务器
- 建议添加防截图保护（`FLAG_SECURE`）
