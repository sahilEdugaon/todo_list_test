import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:todo_test_project/TodoList/todo_controller.dart';

import 'details_screen.dart';

class TodoListScreen extends StatelessWidget {
  TodoListScreen({super.key});

  final TodoController postController = Get.put(TodoController());


  @override
  Widget build(BuildContext context) {

    print('back--');
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List'), centerTitle: true),
      body: Obx(() {
        if (postController.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return PageView.builder(
          controller: postController.pageController, // Using PageController here
          itemCount: postController.postTimers.keys.toList().length,
          scrollDirection: Axis.vertical, // Full page swipe, vertical
          onPageChanged: (index) {
           // postController.generateTimers();
            // Start timer when a new page is scrolled to
            postController.stopTimer(); // Stop the previous post's timer
            postController.startTimerForPost(index);

          },
          itemBuilder: (context, index) {
            var post = postController.posts[index];
            var timer = postController.postTimers[post['id']] ?? 0;
            var isRead = postController.readPosts.contains(post['id']);
            if(index==0){
              postController.startTimerForPost(index);
            }
            print('timmer-$timer');
            return GestureDetector(
              onTap: () async {
                postController.markAsRead(post['id']);

                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(postId: post['id']),)).then((value) {
                  postController.resumeTimer(); // Pause the timer
                });

              },
              child: Container(
                color: isRead ? Colors.white : Colors.yellow[100],
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Main Content (Title and Body preview)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                post['title'].toString().toUpperCase(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 20),
                            Text(post['body'], style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                    // Timer Icon and Text on the right side
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.black),
                          const SizedBox(width: 5),
                          // Text('$timer s', style: const TextStyle(fontSize: 16, color: Colors.black)),
                          Text('$timer s', style: const TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
