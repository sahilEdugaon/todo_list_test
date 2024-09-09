import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo_test_project/TodoList/todo_controller.dart';

class DetailScreen extends StatelessWidget {
  final int postId;

  const DetailScreen({super.key, required this.postId});

  Future<Map<String, dynamic>> fetchPostDetails() async {
    var response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/$postId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = Get.arguments; // Resume the timer if we got a 'resume' result
    print('result-$result');
       Get.find<TodoController>().pauseTimer();
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: FutureBuilder(
        future: fetchPostDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var post = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(post['title'].toString().toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(post['body']),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
