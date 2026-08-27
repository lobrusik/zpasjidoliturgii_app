import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static Future<void> showInterstitialAd(BuildContext context, {required VoidCallback onComplete}) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final Timestamp? adsFreeUntil = data['adsFreeUntil'];

          if (adsFreeUntil != null && adsFreeUntil.toDate().isAfter(DateTime.now())) {
            onComplete(); 
            return;
          }
        }
      } catch (e) {
        debugPrint('Błąd sprawdzania statusu premium: $e');
      }
    }

    _loadAndShowAd(onComplete);
  }

  static void _loadAndShowAd(VoidCallback onComplete) {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              onComplete();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              onComplete();
            },
          );
          
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Błąd ładowania reklamy pełnoekranowej: ${error.message}');
          onComplete(); 
        },
      ),
    );
  }
}