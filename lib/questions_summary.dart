import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary({super.key, required this.summaryData});

  final List<Map<String, Object>> summaryData;

  Widget _buildSummaryText(
    String text,
    Color color, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: GoogleFonts.lato(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children:
              summaryData.map((data) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color:
                            data['user_answer'] == data['correct_answer']
                                ? const Color.fromARGB(255, 118, 140, 246)
                                : const Color.fromARGB(255, 237, 96, 190),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${data['question_index']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryText(
                            '${data['question']}',
                            const Color.fromARGB(255, 255, 253, 253),
                            isBold: true,
                            fontSize: 20,
                          ),
                          const SizedBox(height: 5),
                          _buildSummaryText(
                            '${data['user_answer']}',
                            const Color.fromARGB(255, 244, 132, 207),
                          ),
                          _buildSummaryText(
                            '${data['correct_answer']}',
                            const Color.fromARGB(255, 118, 140, 246),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
