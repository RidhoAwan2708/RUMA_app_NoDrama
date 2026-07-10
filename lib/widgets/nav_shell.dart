import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/user_model.dart';

class NavShell extends StatefulWidget {
  final RumaUser user;
  final int initialIndex;
  final List<NavDestination> destinations;

  const NavShell({
    super.key,
    required this.user,
    this.initialIndex = 0,
    required this.destinations,
  });

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.destinations.map((d) => d.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: widget.destinations.map((d) => BottomNavigationBarItem(
          icon: Icon(d.icon),
          activeIcon: Icon(d.activeIcon ?? d.icon),
          label: d.label,
        )).toList(),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: RumaColors.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: RumaColors.white,
                  child: Text(
                    widget.user.name.isNotEmpty
                        ? widget.user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: RumaColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: RumaColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: RumaColors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(context, '/notifications');
            },
          ),
          if (widget.user.isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: RumaColors.primaryBlue),
              title: const Text('Admin Console', style: TextStyle(color: RumaColors.primaryBlue)),
              onTap: () {
                Navigator.pop(context);
                _navigateTo(context, '/admin');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: RumaColors.dangerRed),
            title: const Text('Logout', style: TextStyle(color: RumaColors.dangerRed)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }
}

class NavDestination {
  final Widget page;
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  NavDestination({
    required this.page,
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
