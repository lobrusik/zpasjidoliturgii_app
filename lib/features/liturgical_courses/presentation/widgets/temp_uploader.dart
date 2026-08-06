import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TempAddPsalmsButton extends StatelessWidget {
  const TempAddPsalmsButton({super.key});

  Future<void> _uploadPsalms(BuildContext context) async {
    final List<Map<String, dynamic>> adventPsalms = [
      {
        'id': 'advent_01',
        'order': 1,
        'title': 'Melodia nr 1',
        'audioUrl': 'https://youtu.be/EHoGK1o5Wgc?si=DJjPVYOGAnZ9srlo',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_02',
        'order': 2,
        'title': 'Melodia nr 2',
        'audioUrl': 'https://youtu.be/ufWN8l8drUY?si=3dWwejBRP9XC4R17',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_03',
        'order': 3,
        'title': 'Melodia nr 3',
        'audioUrl': 'https://youtu.be/k4aO0nlJUqc?si=Ln7OeqZ_OV2tcmao',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_04',
        'order': 4,
        'title': 'Melodia nr 4',
        'audioUrl': 'https://youtu.be/CvUREUeecOM?si=N-tlsSJefFSKuOSQ',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_05',
        'order': 5,
        'title': 'Melodia nr 5',
        'audioUrl': 'https://youtu.be/2MDMaYGmLZM?si=QZ3lq-b4l-M4gp1w',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_06',
        'order': 6,
        'title': 'Melodia nr 6',
        'audioUrl': 'https://youtu.be/obtOqVRy2Ws?si=847PJRAusbEyXuce',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_07',
        'order': 7,
        'title': 'Melodia nr 7',
        'audioUrl': 'https://youtu.be/I9JcTEEViRY?si=IYGue4Swer9E57p5',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_08',
        'order': 8,
        'title': 'Melodia nr 8',
        'audioUrl': 'https://youtu.be/v4xIuw8YJzU?si=wj2Q-U6FbmX5ZLWf',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_09',
        'order': 9,
        'title': 'Melodia nr 9',
        'audioUrl': 'https://youtu.be/t_ArB1zMIco?si=Xyk2n71N4low9mdO',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_10',
        'order': 10,
        'title': 'Melodia nr 10',
        'audioUrl': 'https://youtu.be/8G0dDW09X9c?si=p-r31zh8PIVYnrzz',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_11',
        'order': 11,
        'title': 'Melodia nr 11',
        'audioUrl': 'https://youtu.be/aEPQdIEk9Sc?si=_zCsGbNXAstmvunq',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_12',
        'order': 12,
        'title': 'Melodia nr 12',
        'audioUrl': 'https://youtu.be/FoR7E2jnQUY?si=qPqy1V6gZyrc1u6M',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_13',
        'order': 13,
        'title': 'Melodia nr 13',
        'audioUrl': 'https://youtu.be/eDUnbGkoMvg?si=05PrTqV68T2QcZb9',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_14',
        'order': 14,
        'title': 'Melodia nr 14',
        'audioUrl': 'https://youtu.be/sXihOy_fWAM?si=PNUDQdecxkbMMGto',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_15',
        'order': 15,
        'title': 'Melodia nr 15',
        'audioUrl': 'https://youtu.be/ZtBjZgx2Le0?si=VAEzYlSA6Gs0Ao5a',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_16',
        'order': 16,
        'title': 'Melodia nr 16',
        'audioUrl': 'https://youtu.be/Q5hkXain9I4?si=0sRlentXNH3cq7wX',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_17',
        'order': 17,
        'title': 'Melodia nr 17',
        'audioUrl': 'https://youtu.be/hxb-pmgMv8Q?si=cS7J-xcux4onmN3N',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_18',
        'order': 18,
        'title': 'Melodia nr 18',
        'audioUrl': 'https://youtu.be/DpGryzC6_rs?si=Q-P1Kc085AmBMyxs',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_19',
        'order': 19,
        'title': 'Melodia nr 19',
        'audioUrl': 'https://youtu.be/TVix5a6yYPg?si=Xom7mFMyr48GrVMU',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_20',
        'order': 20,
        'title': 'Melodia nr 20',
        'audioUrl': 'https://youtu.be/w-Fn3C9WJR8?si=3tuyl_W9F8RWmZT-',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_21',
        'order': 21,
        'title': 'Melodia nr 21',
        'audioUrl': 'https://youtu.be/wWyFHetKTXc?si=0-JF5F9ZQWEnML1e',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_22',
        'order': 22,
        'title': 'Melodia nr 22',
        'audioUrl': 'https://youtu.be/E8dO9gER7vI?si=YuZi83tRsGHKaBFV',
        'description': '',
        'category': 'advent',
      },
      {
        'id': 'advent_23',
        'order': 23,
        'title': 'Melodia nr 23',
        'audioUrl': 'https://youtu.be/ba68g1c8J2o?si=JS6LXOENfCqBlwVw',
        'description': '',
        'category': 'advent',
      },
    ];

    try {
      final firestore = FirebaseFirestore.instance;

      for (var psalm in adventPsalms) {
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