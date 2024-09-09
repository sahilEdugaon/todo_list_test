import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoController extends GetxController {
  var posts = [].obs;
  var readPosts = <int>{}.obs;
  var postTimers = Map<int, int>().obs;
  Map storeTime = {}.obs;
  final PageController pageController = PageController();
  Timer? currentTimer;
  int currentPostIndex = 0;
  var remainingSeconds = 10.obs; // Set initial value to 10 seconds
  var isResendAvailable = false.obs; // Tracks if resend is available

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() async {
    var response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      posts.value = jsonData;
       generateTimers();
    }
  }

  void markAsRead(int postId) {
    readPosts.add(postId);
  }

  // Generate random timers for each post (10s, 20s, or 25s)
  void generateTimers() {
    var random = Random();
    for (var post in posts) {
      int randomTime = [10, 20, 25][random.nextInt(3)];
      postTimers[post['id']] = randomTime;
      storeTime[post['id']] = randomTime;
    }
  }



  // Start the timer when the post is in view
  void startTimerForPost(int index) {
    currentTimer?.cancel(); // Cancel any previous timer safely

    var post = posts[index];
    int postId = post['id'];
    int timeLeft = postTimers[postId]??10; // Get remaining time (could be null)

    print('timeLeft-$timeLeft');
    print(postTimers[postId]);

    // Ensure timeLeft is not null and greater than 0
    if (timeLeft != null && timeLeft > 0) {
      currentPostIndex = index;

      currentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        print('currentTimer-$currentTimer');
        if (timeLeft > 0) {
          timeLeft--;
          postTimers[postId] = timeLeft; // Update the remaining time
        print('postTimers=+$postTimers');
        } else {
          timer.cancel(); // Stop the timer if it reaches 0
          postTimers[postId] = storeTime[postId]; // Restart timer with initial value
          startTimerForPost(index); // Restart the timer for the same post
        }
        postTimers.refresh(); // Notify UI to update
      });
    }
  }


  // Stop the current timer when the post goes out of view
  void stopTimer() {
    currentTimer?.cancel();
  }

  void pauseTimer() {
    currentTimer?.cancel();
  }

  void resumeTimer() {
    if (currentPostIndex != null) {
      startTimerForPost(currentPostIndex);
    }
  }

}
