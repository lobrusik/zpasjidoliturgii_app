import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/theme.dart';
import 'app/routes.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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

        return MaterialApp.router(
          title: 'Liturgical App',
          theme: AppTheme.darkTheme,
          routerConfig: AppRoutes.router,

          builder: (context, child) {
            return StreamBuilder<List<ConnectivityResult>>(
              stream: Connectivity().onConnectivityChanged,
              builder: (context, connectivitySnapshot) {
                // make sure the device does NOT have network access
                final isOffline = connectivitySnapshot.hasData &&
                                  connectivitySnapshot.data!.contains(ConnectivityResult.none);
                return Stack(
                  children: [
                    if (child != null) child,
                    // If offline, display an animated red warning bar at the very top
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: isOffline ? 0 : -50,
                      left: 0,
                      right: 0,
                      child: Material(
                        color: Colors.redAccent,
                        child: SafeArea(
                          bottom: false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Brak połączenia z siecią. Przeglądasz pobrane materiały.',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
//start test