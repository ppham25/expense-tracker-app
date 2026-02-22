import 'package:flutter/material.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  final List<Map<String, dynamic>> studyPlan = const [
    {"day": "Day 1", "topic": "Giới thiệu TTCS", "done": true},
    {"day": "Day 2", "topic": "Khái niệm hệ thống máy tính", "done": true},
    {"day": "Day 3", "topic": "Biểu diễn thông tin", "done": false},
    {"day": "Day 4", "topic": "Số nhị phân & mã hóa", "done": false},
    {"day": "Day 5", "topic": "Logic & mạch số", "done": false},
    {"day": "Day 6", "topic": "CPU & bộ nhớ", "done": false},
    {"day": "Day 7", "topic": "Tổng kết & ôn tập", "done": false},
  ];

  @override
  Widget build(BuildContext context) {
    final completed = studyPlan.where((element) => element["done"]).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            "TTCS – Weekly Self Study",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: completed / studyPlan.length,
            backgroundColor: Colors.white24,
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: studyPlan.length,
              itemBuilder: (context, index) {
                final item = studyPlan[index];
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    leading: Icon(
                      item["done"]
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item["done"] ? Colors.greenAccent : Colors.white,
                    ),
                    title: Text(
                      item["day"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      item["topic"],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
