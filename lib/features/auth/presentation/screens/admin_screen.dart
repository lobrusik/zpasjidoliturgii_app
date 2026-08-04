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

  Future<void> _uploadData(String collectionName, String docIdKey) async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      _showMsg('Wklej najpierw kod JSON!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> parsedData = jsonDecode(text);

      final String? docId = parsedData[docIdKey];
      
      if (docId == null || docId.isEmpty) {
        _showMsg('Błąd: W JSON brakuje pola "$docIdKey", które służy jako ID dokumentu!', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection(collectionName).doc(docId).set(parsedData);

      _showMsg('Sukces! Wgrano do $collectionName.', Colors.green);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Wklej tutaj poprawny kod JSON z całą lekcją:'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: '{\n  "courseId": "trunk_02",\n  "title": "..."\n}',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _uploadData('study_plans', 'courseId'),
                    icon: const Icon(Icons.account_tree),
                    label: const Text('Wgraj do Drzewka'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _uploadData('daily_plans', 'dayId'),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Wgraj do Planu'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}