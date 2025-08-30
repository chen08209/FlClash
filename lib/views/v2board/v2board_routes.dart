import 'package:flutter/material.dart';
import 'package:fl_clash/views/v2board/v2board_login_page.dart';
import 'package:fl_clash/views/v2board/v2board_dashboard_page.dart';
import 'package:fl_clash/services/v2board/v2board_api_service.dart';

/// V2Board 路由配置
class V2BoardRoutes {
  static const String login = '/v2board/login';
  static const String dashboard = '/v2board/dashboard';
  
  /// 生成路由
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const V2BoardLoginPage(),
          settings: settings,
        );
        
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const V2BoardDashboardPage(),
          settings: settings,
        );
        
      default:
        return null;
    }
  }
  
  /// 检查用户是否已登录并导航到相应页面
  static Future<void> navigateToAppropriateScreen(BuildContext context) async {
    try {
      final isLoggedIn = await V2BoardApiService.instance.isLoggedIn();
      
      if (isLoggedIn) {
        // 已登录，导航到仪表板
        Navigator.of(context).pushReplacementNamed(dashboard);
      } else {
        // 未登录，导航到登录页面
        Navigator.of(context).pushReplacementNamed(login);
      }
    } catch (e) {
      // 出错时导航到登录页面
      Navigator.of(context).pushReplacementNamed(login);
    }
  }
}

/// V2Board 主入口 Widget
class V2BoardApp extends StatelessWidget {
  const V2BoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V2Board Integration',
      theme: Theme.of(context),
      darkTheme: Theme.of(context),
      themeMode: ThemeMode.system,
      initialRoute: V2BoardRoutes.login,
      onGenerateRoute: V2BoardRoutes.generateRoute,
      home: const V2BoardSplashScreen(),
    );
  }
}

/// V2Board 启动屏幕
class V2BoardSplashScreen extends StatefulWidget {
  const V2BoardSplashScreen({super.key});

  @override
  State<V2BoardSplashScreen> createState() => _V2BoardSplashScreenState();
}

class _V2BoardSplashScreenState extends State<V2BoardSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 等待一小段时间显示启动屏幕
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      await V2BoardRoutes.navigateToAppropriateScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_key,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'V2Board Integration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Connecting to your V2Board panel...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
