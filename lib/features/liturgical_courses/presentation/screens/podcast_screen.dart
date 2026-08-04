import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katechezy ks. Kopy'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('podcasts')
            //.orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Wystąpił błąd pobierania podcastów.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Brak dostępnych katechez.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final podcasts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              final data = podcasts[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Brak tytułu';
              final description = data['description'] ?? 'Brak opisu';

              return Card(
                color: const Color(0xFF2D3039),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF141F1C),
                    radius: 24,
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Trimming Excessively Long Text
                    ),
                  ),
                  trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Odtwarzacz wkrótce!')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}