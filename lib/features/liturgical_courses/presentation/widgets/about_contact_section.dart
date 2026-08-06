import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAndContactSection extends StatelessWidget {
  const AboutAndContactSection({super.key});

  // A function that opens the default email app on your phone
  Future<void> _sendEmail() async {
    const String emails = 'administracja@zpasjidoliturgii.pl, lobrusik@gmail.com';
    final String subject = Uri.encodeComponent('Kontakt z aplikacji Z Pasji do Liturgii');

    final Uri emailLaunchUri = Uri.parse('mailto:$emails?subject=$subject');

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Nie udało się otworzyć aplikacji e-mail: $e');
    }
  }

  //Social Media
  Future<void> _openSocialLink(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }catch (e) {
      debugPrint('Nie udało się otworzyć linku: $e');
    }
  }                                         

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3039),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'O nas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nasz projekt jest internetową inicjatywą świeckich i duchownych, którzy pragną przybliżać wiernym istotę, treść, przepisy i znaczenie świętych obrzędów w różnych rytach liturgicznych. Jeśli podzielasz nasze starania, to zachęcamy do wsparcia naszej działalności.',
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 1. Facebook
              IconButton(
                onPressed: () => _openSocialLink('https://www.facebook.com/Zpasjidoliturgii'),
                icon: const Icon(Icons.facebook, color: Colors.white70),
                tooltip: 'Odwiedź nasz Facebook',
              ),
              // 2. YouTube
              IconButton(
                onPressed: () => _openSocialLink('https://www.youtube.com/@zpasjidoliturgii'),
                icon: const Icon(Icons.play_circle_outline, color: Colors.white70),
                tooltip: 'Nasz kanał YouTube',
              ),
              // 3. Instagram
              IconButton(
                onPressed: () => _openSocialLink('https://www.instagram.com/z_pasji_do_liturgii/'),
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
                tooltip: 'Odwiedź nasz Instagram',
              ),
              // 4. Strona WWW
              IconButton(
                onPressed: () => _openSocialLink('https://zpasjidoliturgii.pl/'),
                icon: const Icon(Icons.language, color: Colors.white70),
                tooltip: 'Strona WWW',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 20),

          const Text(
            'Skontaktuj się z nami',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masz pytania dotyczące kursów, sugestie lub potrzebujesz pomocy technicznej? Jesteśmy do Twojej dyspozycji.',
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Napisz e-mail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}