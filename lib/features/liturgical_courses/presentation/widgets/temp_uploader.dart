import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TempAddPsalmsButton extends StatelessWidget {
  const TempAddPsalmsButton({super.key});

  Future<void> _uploadPsalms(BuildContext context) async {
    final List<Map<String, dynamic>> ordinaryPsalms = [
      {
        'id': 'ordinary_01',
        'order': 1,
        'title': 'Melodia nr 1',
        'audioUrl': 'https://youtu.be/jZ7TidhYFLM?si=VEwSmZHGcY5A0D_8',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_02',
        'order': 2,
        'title': 'Melodia nr 2',
        'audioUrl': 'https://youtu.be/Bc4XxJxJcqg?si=wZs8ScXW_YfTVMtd',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_03',
        'order': 3,
        'title': 'Melodia nr 3',
        'audioUrl': 'https://youtu.be/tSEjGDXSamY?si=yie0geUg5VHKmmO3',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_04',
        'order': 4,
        'title': 'Melodia nr 4',
        'audioUrl': 'https://youtu.be/i60r3of_4Kc?si=ZG9fWZI3QedNsq3W',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_05',
        'order': 5,
        'title': 'Melodia nr 5',
        'audioUrl': 'https://youtu.be/-IvY0W4VXRI?si=4lvJiZh2vjJOOyyq',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_06',
        'order': 6,
        'title': 'Melodia nr 6',
        'audioUrl': 'https://youtu.be/BYem-dvZCVU?si=BybcL_X5fsPNil8b',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_07',
        'order': 7,
        'title': 'Melodia nr 7',
        'audioUrl': 'https://youtu.be/ePdCek1wums?si=_ZlPuKsSsVXmMJh1',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_08',
        'order': 8,
        'title': 'Melodia nr 8',
        'audioUrl': 'https://youtu.be/mNe5krLLw7A?si=-NWdHTCBIu6lzTbq',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_09',
        'order': 9,
        'title': 'Melodia nr 9',
        'audioUrl': 'https://youtu.be/2RBkK7iizqo?si=Y2rFtWs-sTLdWADg',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_10',
        'order': 10,
        'title': 'Melodia nr 10',
        'audioUrl': 'https://youtu.be/wiyh6cND97Y?si=JeIDZbOme8G9htHh',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_11',
        'order': 11,
        'title': 'Melodia nr 11',
        'audioUrl': 'https://youtu.be/IypUi4MLjj4?si=srXoWEB3lpezoqqW',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_12',
        'order': 12,
        'title': 'Melodia nr 12',
        'audioUrl': 'https://youtu.be/uHqcXkELEB8?si=0oWPw2rhcICy_kku',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_13',
        'order': 13,
        'title': 'Melodia nr 13',
        'audioUrl': 'https://youtu.be/XQx2MI8ntxw?si=AYwh2xybWv96BtNv',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_14',
        'order': 14,
        'title': 'Melodia nr 14',
        'audioUrl': 'https://youtu.be/wvRwtfHve8U?si=sNs2uATm0a_892Oj',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_15',
        'order': 15,
        'title': 'Melodia nr 15',
        'audioUrl': 'https://youtu.be/GgR_W8hU4zk?si=clGmNdoG0HGvlk8H',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_16',
        'order': 16,
        'title': 'Melodia nr 16',
        'audioUrl': 'https://youtu.be/4P2xMDSKn8M?si=GcTykSXovUpv9-9j',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_17',
        'order': 17,
        'title': 'Melodia nr 17',
        'audioUrl': 'https://youtu.be/Yw-joRMWiMc?si=AulL200ko7kHJaRx',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_18',
        'order': 18,
        'title': 'Melodia nr 18',
        'audioUrl': 'https://youtu.be/XV8XknJ4n-0?si=bL71blEFkx30qTCi',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_19',
        'order': 19,
        'title': 'Melodia nr 19',
        'audioUrl': 'https://youtu.be/qj0Ct5b5WKI?si=Ju6VEFIMQZYTHKgm',
        'description': '',
        'category': 'ordinary',
      },
      {
        'id': 'ordinary_20',
        'order': 20,
        'title': 'Melodia nr 20',
        'audioUrl': 'https://youtu.be/O7w2unLTO8k?si=95CDi_i4w81_jkTD',
        'description': '',
        'category': 'ordinary',
      },
    ];

    try {
      final firestore = FirebaseFirestore.instance;

      for (var psalm in ordinaryPsalms) {
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