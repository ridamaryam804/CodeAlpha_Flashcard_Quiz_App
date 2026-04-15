import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'result_screen.dart';


class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          _buildNavButton(
            context,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen()),
                    (route) => false,
              );
            },
          ),

          // Results Button
          _buildNavButton(
            context,
            icon: Icons.bar_chart,
            label: 'Results',
            isSelected: currentIndex == 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white60,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}