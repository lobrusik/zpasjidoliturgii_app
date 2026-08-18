import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'psalm_video_screen.dart';

class PsalmsListScreen extends StatelessWidget {
  final String title;
  final String collectionName;
  final String category;

  const PsalmsListScreen({
    super.key,
    required this.title,
    required this.collectionName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('category', isEqualTo: category);

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
                'Brak dostępnych psalmów w sekcji:\n$title',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final psalms = snapshot.data!.docs.toList();

          psalms.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aOrder = aData['order'] ?? 0;
            final bOrder = bData['order'] ?? 0;
            return aOrder.compareTo(bOrder);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: psalms.length,
            itemBuilder: (context, index) {
              final data = psalms[index].data() as Map<String, dynamic>;
              final itemTitle = data['title'] ?? 'Brak tytułu';
              final description = data['description'] ?? '';
              
              final videoUrl = data['youtubeUrl'] ?? data['videoUrl'] ?? data['audioUrl'] ?? ''; 

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
                    child: Icon(Icons.music_note, color: Colors.white), 
                  ),
                  title: Text(
                    itemTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: description.isNotEmpty 
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          description,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : null,
                  trailing: const Icon(Icons.ondemand_video, color: Colors.white, size: 28),
                  onTap: () {
                    if (videoUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PsalmVideoScreen(
                            title: itemTitle,
                            youtubeUrl: videoUrl,
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