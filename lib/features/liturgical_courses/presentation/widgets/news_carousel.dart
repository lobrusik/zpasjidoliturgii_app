import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:html_unescape/html_unescape.dart';

class NewsCarousel extends StatelessWidget {
  const NewsCarousel({super.key});

  Future<List> fetchNews() async {
    final response = await http.get(Uri.parse('https://zpasjidoliturgii.pl/wp-json/wp/v2/posts?per_page=5'));
    return json.decode(response.body);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // I love wordpress texts
  String _cleanText(String rawText) async {
    if (rawText.isEmpty) return '';

    String text = rawText.replaceAll(RegExp(r'<[^>]*>'), '');
    text = HtmlUnescape().convert(text);

    return text
        .replaceAll('&#8222;', '„')
        .replaceAll('&#8221;', '”')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—') 
        .replaceAll('&#8216;', '‘')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8230;', '...') 
        .replaceAll('[&hellip;]', '...');
  }

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();

    return FutureBuilder(
      future: fetchNews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data as List;

        return CarouselSlider.builder(
          itemCount: posts.length,
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
          itemBuilder: (context, index, realIndex) {
            final post = posts[index];

            final cleanTitle = _cleanText(post['title']['rendered']);
            var cleanExcerpt = _cleanText(post['excerpt']['rendered']);

            cleanExcerpt = cleanExcerpt.replaceAll('[&hellip;]', '...');

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF2D3039),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cleanExcerpt,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _launchURL(post['link']),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Czytaj więcej',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}