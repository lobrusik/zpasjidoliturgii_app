import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TempAddPsalmsButton extends StatelessWidget {
  const TempAddPsalmsButton({super.key});

  Future<void> _uploadPsalms(BuildContext context) async {
    final List<Map<String, dynamic>> easterPsalms = [
      {
        'id': 'easter_01',
        'order': 1,
        'title': 'Melodia nr 1',
        'audioUrl': 'https://youtu.be/hyeOQpKvELY?si=bqhG1kox6bQV-zBg',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_02',
        'order': 2,
        'title': 'Melodia nr 2',
        'audioUrl': 'https://youtu.be/DPi7PEUduHw?si=K3kjaagIZ2qatU8r',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_03',
        'order': 3,
        'title': 'Melodia nr 3',
        'audioUrl': 'https://youtu.be/e_Vhxf3KLL0?si=aJj2zms4OmoYNauG',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_04',
        'order': 4,
        'title': 'Melodia nr 4',
        'audioUrl': 'https://youtu.be/OHlium4q11s?si=LGZMYSAXgQvQ2P4e',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_05',
        'order': 5,
        'title': 'Melodia nr 5',
        'audioUrl': 'https://youtu.be/-1PORXdpKi4?si=R6pPOiuwMZMrJolp',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_06',
        'order': 6,
        'title': 'Melodia nr 6',
        'audioUrl': 'https://youtu.be/vdZfKcU9e40?si=DUvLQAzxF_1F1BGH',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_07',
        'order': 7,
        'title': 'Melodia nr 7',
        'audioUrl': 'https://youtu.be/LFJuMqmfsoA?si=bavb0aBL4u7WmEgL',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_08',
        'order': 8,
        'title': 'Melodia nr 8',
        'audioUrl': 'https://youtu.be/loMrId-BZxM?si=Fqt79i5tmtUvPWPw',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_09',
        'order': 9,
        'title': 'Melodia nr 9',
        'audioUrl': 'https://youtu.be/H_XHjMY59ZI?si=gtahiNkYD43B1bgd',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_10',
        'order': 10,
        'title': 'Melodia nr 10',
        'audioUrl': 'https://youtu.be/h2Y_SunU_UQ?si=C1_kEug5UcXAY4g8',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_11',
        'order': 11,
        'title': 'Melodia nr 11',
        'audioUrl': 'https://youtu.be/8IR0ET94rrY?si=zvgW3qUYGOdA3ysw',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_12',
        'order': 12,
        'title': 'Melodia nr 12',
        'audioUrl': 'https://youtu.be/pYM8xnnf6Wk?si=yR9FIw7yVahTz0jd',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_13',
        'order': 13,
        'title': 'Melodia nr 13',
        'audioUrl': 'https://youtu.be/fGlc5F9MLcg?si=h5ntnjns4F6TEnFr',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_14',
        'order': 14,
        'title': 'Melodia nr 14',
        'audioUrl': 'https://youtu.be/ob3VslqIJzs?si=V5lQfsCtE4UmS7Dg',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_15',
        'order': 15,
        'title': 'Melodia nr 15',
        'audioUrl': 'https://youtu.be/Wvu1Yiwk4Ew?si=qb3qIIHjgWX4taDC',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_16',
        'order': 16,
        'title': 'Melodia nr 16',
        'audioUrl': 'https://youtu.be/6IzmSdd4G5M?si=6dlTcOpc2tlLchil',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_17',
        'order': 17,
        'title': 'Melodia nr 17',
        'audioUrl': 'https://youtu.be/or1gM4e3Ur4?si=hoST9NTfx7dGbHRj',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_18',
        'order': 18,
        'title': 'Melodia nr 18',
        'audioUrl': 'https://youtu.be/NZuI6sexBgY?si=K3j5fZq-sooPqLID',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_19',
        'order': 19,
        'title': 'Melodia nr 19',
        'audioUrl': 'https://youtu.be/rVkCypBdwyQ?si=4hcfjrYnwl6JgD1j',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_20',
        'order': 20,
        'title': 'Melodia nr 20',
        'audioUrl': 'https://youtu.be/en-qtE0XRJc?si=KOEdqSELuJRTppfu',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_21',
        'order': 21,
        'title': 'Melodia nr 21',
        'audioUrl': 'https://youtu.be/v1CjUY9aFBA?si=l0tCduWAa1hJorpO',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_22',
        'order': 22,
        'title': 'Melodia nr 22',
        'audioUrl': 'https://youtu.be/y9GH5tMoDjY?si=Zezh0dJS15FOktdi',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_23',
        'order': 23,
        'title': 'Melodia nr 23',
        'audioUrl': 'https://youtu.be/fEigTs8QQwI?si=X_FJqEKXZf_FJIoi',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_24',
        'order': 24,
        'title': 'Melodia nr 24',
        'audioUrl': 'https://youtu.be/9cMo8okMI3U?si=cTNy8VJmZDTZVJmF',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_25',
        'order': 25,
        'title': 'Melodia nr 25',
        'audioUrl': 'https://youtu.be/UntVZ8ORnDU?si=E2OSVlvFkijPnZ8H',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_26',
        'order': 26,
        'title': 'Melodia nr 26',
        'audioUrl': 'https://youtu.be/7oasACitbwo?si=OFOamJ1QdXVjdmdz',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_27',
        'order': 27,
        'title': 'Melodia nr 27',
        'audioUrl': 'https://youtu.be/32aTrdJTreI?si=SW1GaJ55DJ4TZFWM',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_28',
        'order': 28,
        'title': 'Melodia nr 28',
        'audioUrl': '',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_29',
        'order': 29,
        'title': 'Melodia nr 29',
        'audioUrl': 'https://youtu.be/05q4xxltjv4?si=NIqoHKDvHt-6wBwr',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_30',
        'order': 30,
        'title': 'Melodia nr 30',
        'audioUrl': 'https://youtu.be/-COwcSnQ94k?si=bcDW1K0lYDr-uCWe',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_31',
        'order': 31,
        'title': 'Melodia nr 31',
        'audioUrl': 'https://youtu.be/wTSexCj4DHE?si=AVCzhQSOhsJ1UYMf',
        'description': '',
        'category': 'easter',
      },
      {
        'id': 'easter_32',
        'order': 32,
        'title': 'Melodia nr 32',
        'audioUrl': 'https://youtu.be/xYzdX_fS5MQ?si=c8PF3EMiW9cLIyVh',
        'description': '',
        'category': 'easter',
      },
    ];

    try {
      final firestore = FirebaseFirestore.instance;

      for (var psalm in easterPsalms) {
        final docId = psalm['id'] as String;
        await firestore.collection('psalms').doc(docId).set({
          'audioUrl': psalm['audioUrl'],
          'category': psalm['category'],
          'description': psalm['description'],
          'order': psalm['order'],
          'title': psalm['title'],
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sukces!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => _uploadPsalms(context),
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Wgraj wszystko'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}