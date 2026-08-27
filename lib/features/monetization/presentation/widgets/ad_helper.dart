import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdHelper {
  static Future<void> showInterstitialAd(BuildContext context, {required VoidCallback onComplete}) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      _showAdMock(context, onComplete);
      return;
    }

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
      
      if (context.mounted) _showAdMock(context, onComplete);
      
    } catch (e) {
      onComplete();
    }
  }

  static void _showAdMock(BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'REKLAMA\n(Tu w przyszłości będzie wideo\nlub duży baner AdMob)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 36),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onComplete();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}