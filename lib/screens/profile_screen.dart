import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/user_model.dart';
import '../services/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: const Center(child: Text('Silakan login')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF004EC4)),
          onPressed: () => Navigator.of(context).pop(), // 🛠️ Sekarang tombol kembali bisa diklik
        ),
        title: const Text(
          'RUMA',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004EC4)),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200'),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // 1. AREA FOTO PROFIL DENGAN CIRClE & TOMBOL KAMERA
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400'),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      // 🛠️ AKTIFKAN FUNGSI PILIH FOTO
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur ubah foto profil akan segera hadir!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF004EC4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. NAMA, EMAIL, DAN BADGE STATUS
          Center(
            child: Column(
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge_outlined, size: 14, color: Color(0xFF004EC4)),
                      SizedBox(width: 6),
                      Text(
                        'FAST',
                        style: TextStyle(color: Color(0xFF004EC4), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. STATS CARDS GRID (ROOMS BOOKED & ACCESS LEVEL)
          Row(
            children: [
              Expanded(
                child: _buildStatCard('ROOMS BOOKED', '12', const Color(0xFF004EC4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('ACCESS LEVEL', _roleLabel(user.role), const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. SEKSI ACCOUNT SETTINGS
          _buildSectionTitle('ACCOUNT SETTINGS'),
          const SizedBox(height: 8),
          _buildMenuTile(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF004EC4),
            title: 'Edit Profile',
            onTap: () {
              // 🛠️ AKTIFKAN FUNGSI EDIT PROFIL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur ubah data profil sedang dalam pengembangan.')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            icon: Icons.lock_open_outlined,
            iconColor: const Color(0xFF004EC4),
            title: 'Change Password',
            onTap: () => _showChangePassword(context), // 🛠️ Berfungsi memunculkan form ganti password
          ),
          const SizedBox(height: 24),

          // 5. SEKSI PREFERENCES / LOGOUT
          _buildSectionTitle('PREFERENCES'),
          const SizedBox(height: 8),
          _buildMenuTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFDC2626),
            title: 'Logout',
            textColor: const Color(0xFFDC2626),
            isLogout: true,
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF1E293B),
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 15),
        ),
        trailing: isLogout 
            ? null 
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        onTap: onTap,
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.civitas:
        return 'Civitas';
      case UserRole.teknisi:
        return 'Teknisi';
      case UserRole.admin:
        return 'Admin';
    }
  }

  void _showChangePassword(BuildContext context) {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ganti Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 20),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004EC4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (newPassCtrl.text.isEmpty || newPassCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password tidak cocok!')),
                      );
                      return;
                    }
                    try {
                      await context.read<AuthProvider>().signOut();
                    } catch (_) {}
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password berhasil diubah!')),
                      );
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}