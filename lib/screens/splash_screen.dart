import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/auth_provider.dart';
import '../services/firestore_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menjalankan inisialisasi aman setelah framework selesai melakukan build widget pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    if (!mounted) return;
    context.read<FirestoreProvider>().loadRooms();
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RumaColors.primaryBlue, Color(0xFF143FA0)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: RumaColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.meeting_room_outlined,
                size: 56,
                color: RumaColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RUMA',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: RumaColors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Room Utility Management Assistant',
              style: TextStyle(
                fontSize: 14,
                color: RumaColors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(RumaColors.white),
            ),
          ],
        ),
      ),
    );
  }
}