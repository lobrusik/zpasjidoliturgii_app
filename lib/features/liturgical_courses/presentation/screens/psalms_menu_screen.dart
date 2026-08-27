import 'package:flutter/material.dart';
import 'psalms_list_screen.dart';

class PsalmsMenuScreen extends StatelessWidget {
  const PsalmsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Melodie Psalmów... i nie tylko'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          //ADVENT
          _buildPeriodCard(
            context,
            title: 'Adwent',
            subtitle: 'Psalmy na okres adwentowy',
            icon: Icons.brightness_3,
            category: 'advent',
          ),
          const SizedBox(height: 12),

          //EASTER
          _buildPeriodCard(
            context,
            title: 'Wielkanoc',
            subtitle: 'Psalmy na okres wielkanocny',
            icon: Icons.wb_sunny,
            category: 'easter',
          ),
          const SizedBox(height: 12),

          //ORDINARY
          _buildPeriodCard(
            context,
            title: 'Okres Zwykły',
            subtitle: 'Psalmy na okres zwykły',
            icon: Icons.calendar_today,
            category: 'ordinary',
          ),

          //SEQUENCES
          _buildPeriodCard(
            context,
            title: 'Sekwencje',
            subtitle: 'Melodie sekwencji',
            icon: Icons.local_attraction,
            category: 'sequences',
          ),

          //ALLLELUJA
          _buildPeriodCard(
            context,
            title: 'Alleluja',
            subtitle: 'Melodie aklamacji „Alleluja”',
            icon: Icons.insert_emoticon,
            category: 'alleluja',
          ),

          //TRIDUUM
          _buildPeriodCard(
            context,
            title: 'Triduum',
            subtitle: 'Melodie na Triduum Paschalne',
            icon: Icons.cloud,
            category: 'triduum',
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String category,
  }) {
    return Card(
      color: const Color(0xFF2D3039),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF141F1C),
          radius: 24,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
        onTap: () {
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PsalmsListScreen(
                title: 'Psalmy: $title',
                collectionName: 'psalms',
                category: category, //'advent', 'easter', 'ordinary'
              ),
            ),
          );
        },
      ),
    );
  }
}