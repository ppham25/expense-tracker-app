import 'package:adv_basic/data/questions.dart';
import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'question_screen.dart';
import 'result_screen.dart';

class Quizz extends StatefulWidget {
  const Quizz({super.key});

  @override
  State<Quizz> createState() => _QuizzState();
}

class _QuizzState extends State<Quizz> {
  final List<String> selectedAnswers = [];
  var activeScreen = "start-screen";

  void switchScreen() {
    setState(() {
      if (activeScreen == "start-screen") {
        activeScreen = "question-screen";
      } else {
        selectedAnswers.clear();
        activeScreen = "start-screen";
      }
    });
  }

  void chooseAnswer(String answer) {
    selectedAnswers.add(answer);
    if (selectedAnswers.length == questions.length) {
      setState(() {
        activeScreen = "result-screen";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidget =
        activeScreen == "start-screen"
            ? StartScreen(switchScreen)
            : activeScreen == "result-screen"
            ? ResultScreen(
              restartQuiz: switchScreen,
              choosenAnswers: selectedAnswers,
            )
            : QuestionScreen(oneSelectAnswer: chooseAnswer);
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
