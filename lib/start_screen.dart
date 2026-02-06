import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen(this.startQuiz, {super.key});

  final void Function() startQuiz;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/quiz-logo.png",
            width: 200,
            color: const Color.fromARGB(186, 244, 244, 244),
          ),
          const SizedBox(height: 20),
          const Text(
            "Let's get started!",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          OutlinedButton.icon(
            onPressed: () {
              startQuiz();
            },
            // style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
            icon: Icon(Icons.arrow_right_alt, color: Colors.white),
            label: Text("start quiz", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
