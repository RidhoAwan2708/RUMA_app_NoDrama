import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/scan_qr_screen.dart';
import '../screens/room_detail_screen.dart';
import '../screens/report_issue_screen.dart';
import '../screens/report_detail_screen.dart';
import '../screens/maintenance_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/admin_console_screen.dart';
import '../widgets/nav_shell.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (ctx) {
          final user = ctx.watch<AuthProvider>().user;
          if (user == null) {
            return const LoginScreen();
          }
          return NavShell(
            user: user,
            initialIndex: 0,
            destinations: [
              NavDestination(
                page: const DashboardScreen(),
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Beranda',
              ),
              NavDestination(
                page: const ScanQRScreen(),
                icon: Icons.qr_code_scanner_outlined,
                activeIcon: Icons.qr_code_scanner,
                label: 'Scan QR',
              ),
              NavDestination(
                page: const MaintenanceHistoryScreen(),
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'Riwayat',
              ),
              NavDestination(
                page: const NotificationsScreen(),
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Notifikasi',
              ),
            ],
          );
        });
      case '/scan-qr':
        return MaterialPageRoute(builder: (_) => const ScanQRScreen());
      case '/room-detail':
        return MaterialPageRoute(builder: (_) => const RoomDetailScreen());
      case '/report-issue':
        return MaterialPageRoute(builder: (_) => const ReportIssueScreen());
      case '/report-detail':
        return MaterialPageRoute(builder: (_) => const ReportDetailScreen());
      case '/history':
        return MaterialPageRoute(
            builder: (_) => const MaintenanceHistoryScreen());
      case '/notifications':
        return MaterialPageRoute(
            builder: (_) => const NotificationsScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/admin':
        return MaterialPageRoute(builder: (ctx) {
          final user = ctx.watch<AuthProvider>().user;
          if (user == null) return const LoginScreen();
          return NavShell(
            user: user,
            initialIndex: 0,
            destinations: [
              NavDestination(
                page: const AdminConsoleScreen(),
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
              ),
              NavDestination(
                page: const ScanQRScreen(),
                icon: Icons.qr_code_scanner_outlined,
                activeIcon: Icons.qr_code_scanner,
                label: 'Scan QR',
              ),
              NavDestination(
                page: const NotificationsScreen(),
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Notifikasi',
              ),
            ],
          );
        });
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
