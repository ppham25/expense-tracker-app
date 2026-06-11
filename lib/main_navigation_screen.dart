import 'package:adv_basic/features/budget/budget_screen.dart';
import 'package:adv_basic/features/statistics/statistic_screen.dart';
import 'package:adv_basic/features/profile/profile_screen.dart';
import 'package:adv_basic/features/expenses/expenses_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      Expenses(onGoToBudget: () => _selectTab(2)),
      const StatisticsScreen(),
      const BudgetScreen(),
      const ProfileScreen(),
    ];
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statis'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        iconSize: 30,
        selectedFontSize: 24,
        unselectedFontSize: 20,
      ),
    );
  }
}
