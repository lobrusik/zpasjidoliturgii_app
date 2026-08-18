import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audio_podcast_player_screen.dart';

class PodcastScreen extends StatelessWidget {
  final String title;
  final String collectionName;
  final String? category;

  const PodcastScreen({
    super.key,
    this.title = 'Katechezy ks. Mateusza Kopy',
    this.collectionName = 'podcast',
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection(collectionName);
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Wystąpił błąd pobierania materiałów.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Brak dostępnych nagrań w sekcji:\n$title',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final podcast = snapshot.data!.docs.toList();

          podcast.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aOrder = aData['order'] ?? 0;
            final bOrder = bData['order'] ?? 0;
            return aOrder.compareTo(bOrder);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: podcast.length,
            itemBuilder: (context, index) {
              final data = podcast[index].data() as Map<String, dynamic>;
              final itemTitle = data['title'] ?? 'Brak tytułu';
              final description = data['description'] ?? 'Brak opisu';

              final audioUrl = data['youtubeUrl'] ?? data['videoUrl'] ?? data['audioUrl'] ?? data['audoUrl'] ?? '';

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
                    child: Icon(Icons.headphones, color: Colors.white),
                  ),
                  title: Text(
                    itemTitle,
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                  onTap: () {
                    if (audioUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPodcastPlayerScreen(
                            title: itemTitle,
                            audioUrl: audioUrl,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Brak linku do wideo')),
                      );
                    }
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