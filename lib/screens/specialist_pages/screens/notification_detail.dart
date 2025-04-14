import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final String? tappedPayload;

  const NotificationScreen({super.key, this.tappedPayload});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> payloadData = {};

    if (tappedPayload != null && tappedPayload!.isNotEmpty) {
      try {
        payloadData = jsonDecode(tappedPayload!);
      } catch (e) {
        payloadData = {"error": "Invalid payload format"};
      }
    }

    final title = payloadData['title'];
    final body = payloadData['body'];

    // Remove title and body from map to prevent duplicates
    payloadData.remove('title');
    payloadData.remove('body');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (payloadData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: payloadData.length,
                  itemBuilder: (context, index) {
                    final entry = payloadData.entries.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_beautifyKey(entry.key)}: ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(entry.value.toString()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _beautifyKey(String key) {
    return key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
      return '${match.group(1)} ${match.group(2)}';
    }).replaceFirst(key[0], key[0].toUpperCase());
  }
}
