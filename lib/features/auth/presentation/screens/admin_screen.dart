import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _jsonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _uploadData(String collectionName, {String? docIdKey, bool useAutoId = false}) async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      _showMsg('Wklej najpierw kod JSON!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final decodedData = jsonDecode(text);
      final List<dynamic> dataList = decodedData is List ? decodedData : [decodedData];

      for (var item in dataList) {
        final Map<String, dynamic> parsedData = item as Map<String, dynamic>;

        if (useAutoId) {
          await FirebaseFirestore.instance.collection(collectionName).add(parsedData);
        } else {
          final String? docId = parsedData[docIdKey];
          
          if (docId == null || docId.isEmpty) {
            _showMsg('Błąd: W JSON brakuje pola "$docIdKey" w jednym z dokumentów!', Colors.red);
            setState(() => _isLoading = false);
            return;
          }

          await FirebaseFirestore.instance.collection(collectionName).doc(docId).set(parsedData);
        }
      }

      _showMsg('Sukces! Wgrano ${dataList.length} element(ów) do $collectionName.', Colors.green);
      _jsonController.clear();
      
    } catch (e) {
      _showMsg('Błąd formatu JSON: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administratora'), backgroundColor: Colors.red.shade900),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Wklej tutaj poprawny kod JSON:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300, 
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '{\n  "courseId": "trunk_02",\n  "title": "..."\n}\n\nLUB DLA GRY:\n{\n  "lvl": 1,\n  "word": "ALBA",\n  "description": "Biała szata liturgiczna..."\n}',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _uploadData('study_plans', docIdKey: 'courseId'),
                          icon: const Icon(Icons.account_tree),
                          label: const Text('Wgraj do Drzewka', textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _uploadData('interactive_lessons', docIdKey: 'courseId'),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Wgraj interaktywną lekcję', textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _uploadData('liturgical_terms', useAutoId: true),
                      icon: const Icon(Icons.spellcheck),
                      label: const Text('Wgraj słowo do gry'),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}