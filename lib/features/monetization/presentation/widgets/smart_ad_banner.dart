import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartAdBanner extends StatelessWidget {
  const SmartAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) return _buildPlaceholderAd();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildPlaceholderAd();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final Timestamp? adsFreeUntil = data['adsFreeUntil'];

        if (adsFreeUntil != null && adsFreeUntil.toDate().isAfter(DateTime.now())) {
          return const SizedBox.shrink();
        }

        return _buildPlaceholderAd();
      },
    );
  }

  Widget _buildPlaceholderAd() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: const Text(
        'Reklama Google (Baner AdMob)',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}