import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/firebase_options.dart';
import 'services/auth_provider.dart';
import 'services/firestore_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
      ],
      child: const RumaApp(),
    ),
  );
}

class RumaApp extends StatelessWidget {
  const RumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUMA',
      debugShowCheckedModeBanner: false,
      theme: RumaTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
