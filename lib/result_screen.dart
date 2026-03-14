import 'package:adv_basic/data/questions.dart';
import 'package:flutter/material.dart';
import 'package:adv_basic/questions_summary.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({
    required this.restartQuiz,
    super.key,
    required this.choosenAnswers,
  });

  final void Function() restartQuiz;
  final List<String> choosenAnswers;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];
    for (var i = 0; i < choosenAnswers.length; i++) {
      summary.add({
        'question_index': i + 1,
        'question': questions[i].text,
        'correct_answer': questions[i].answers[0],
        'user_answer': choosenAnswers[i],
      });
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final numCorrectAnswers =
        getSummaryData()
            .where((data) => data['user_answer'] == data['correct_answer'])
            .length;
    return Container(
      margin: const EdgeInsets.all(40),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You answered ${numCorrectAnswers} out of ${questions.length} questions correctly!',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          Expanded(child: QuestionsSummary(summaryData: getSummaryData())),
          SizedBox(height: 10),
          TextButton.icon(
            onPressed: restartQuiz,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text("Restart Quiz", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
