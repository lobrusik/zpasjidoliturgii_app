import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SmartAdBanner extends StatelessWidget {
  const SmartAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) return const _RealBannerAd();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const _RealBannerAd();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final Timestamp? adsFreeUntil = data['adsFreeUntil'];

        if (adsFreeUntil != null && adsFreeUntil.toDate().isAfter(DateTime.now())) {
          return const SizedBox.shrink();
        }

        return const _RealBannerAd();
      },
    );
  }
}

class _RealBannerAd extends StatefulWidget {
  const _RealBannerAd();

  @override
  State<_RealBannerAd> createState() => _RealBannerAdState();
}

class _RealBannerAdState extends State<_RealBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Błąd ładowania banera: ${err.message}');
          ad.dispose(); 
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    return const SizedBox(height: 50); 
  }
}