import 'package:flutter/material.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary({super.key, required this.summaryData});

  final List<Map<String, Object>> summaryData;
  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          summaryData.map((data) {
            return Row(
              children: [
                Text('${data['question_index']}'),
                Column(
                  children: [
                    Text('${data['question']}'),
                    SizedBox(height: 5),
                    Text('${data['user_answer']}'),
                    Text('${data['correct_answer']}'),
                  ],
                ),
              ],
            );
          }).toList(),
    );
  }
}
