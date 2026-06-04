import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_media_hub/theme/theme_provider.dart';
import 'package:smart_media_hub/theme/app_theme.dart';
import 'package:smart_media_hub/routes/app_router.dart';
import 'package:flutter/foundation.dart';

const firebaseConfig = {
  "apiKey": "AIzaSyDF0lttu8fTw940wI6YmjJYXRLzV-q1F8Y",
  "authDomain": "smartmediahub-82857.firebaseapp.com",
  "projectId": "smartmediahub-82857",
  "storageBucket": "smartmediahub-82857.firebasestorage.app",
  "messagingSenderId": "681002979803",
  "appId": "1:681002979803:web:5c41a04ee66ddb632357fe"
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDF0lttu8fTw940wI6YmjJYXRLzV-q1F8Y",
        authDomain: "smartmediahub-82857.firebaseapp.com",
        projectId: "smartmediahub-82857",
        storageBucket: "smartmediahub-82857.firebasestorage.app",
        messagingSenderId: "681002979803",
        appId: "1:681002979803:web:5c41a04ee66ddb632357fe",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SmartMediaHub(),
    ),
  );
}

class SmartMediaHub extends StatelessWidget {
  const SmartMediaHub({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp.router(
      title: 'Smart Media Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
