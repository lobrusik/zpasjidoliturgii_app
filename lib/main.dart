import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/theme.dart';
import 'app/routes.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pl_PL', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  runApp(const LiturgicalApp());
}

class LiturgicalApp extends StatelessWidget {
  const LiturgicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        AppRoutes.router.refresh();

        return ValueListenableBuilder<bool>(
          valueListenable: SettingsManager.isHighContrast,
          builder: (context, isHighContrast, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Liturgical App',

              theme: isHighContrast 
                  ? AppTheme.darkTheme.copyWith(
                      textTheme: AppTheme.darkTheme.textTheme.apply(
                        bodyColor: Colors.yellowAccent,
                        displayColor: Colors.yellowAccent,
                        decorationColor: Colors.yellowAccent,
                      ),
                      primaryTextTheme: AppTheme.darkTheme.primaryTextTheme.apply(
                        bodyColor: Colors.yellowAccent,
                        displayColor: Colors.yellowAccent,
                      ),
                      appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
                        foregroundColor: Colors.yellowAccent,
                        iconTheme: const IconThemeData(color: Colors.yellowAccent),
                        titleTextStyle: const TextStyle(
                          color: Colors.yellowAccent, 
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      listTileTheme: const ListTileThemeData(
                        textColor: Colors.yellowAccent,
                        iconColor: Colors.yellowAccent,
                      ),
                      iconTheme: const IconThemeData(color: Colors.yellowAccent),
                    )
                  : AppTheme.darkTheme,
            routerConfig: AppRoutes.router,
            );
          },
        );
      }, 
    );
  }
}