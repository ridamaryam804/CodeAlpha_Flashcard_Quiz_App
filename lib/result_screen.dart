import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

// Global list to store all quiz results
List<Map<String, dynamic>> quizResults = [];

// Global function to add result from anywhere
void addQuizResult(String category, String difficulty, String score, int flipCount) {
  quizResults.insert(0, {
    'category': category,
    'difficulty': difficulty,
    'score': score,
    'flipCount': flipCount,
    'dateTime': DateTime.now(),
  });
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    bool hasResults = quizResults.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4E8BC4),
              Color(0xFF97CBFB),
              Color(0xFFFFC2D9),
              Color(0xFFFF99BE),
              Color(0xFFFF6DA2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Center Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back Arrow (Left)
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    // Center Text
                    Center(
                      child: Text(
                        'Daily Results',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Expanded(
                child: hasResults
                    ? _buildResultsList()
                    : _buildEmptyState(),
              ),

              BottomNavBar(currentIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 80, color: Colors.white.withOpacity(0.5)),
          SizedBox(height: 20),
          Text('No results yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white70)),
          SizedBox(height: 10),
          Text('Complete a quiz to see your scores!', style: TextStyle(fontSize: 16, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: quizResults.length,
      itemBuilder: (context, index) {
        final result = quizResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    DateTime dateTime = result['dateTime'];
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String formattedTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';


    Color difficultyColor;
    switch (result['difficulty']) {
      case 'Easy':
        difficultyColor = Color(0xFFEF8BB0);
        break;
      case 'Medium':
        difficultyColor = Color(0xFFC767F3);
        break;
      case 'Hard':
        difficultyColor = Color(0xFFF44336);
        break;
      default:
        difficultyColor = Colors.grey;
    }


    Color categoryColor;
    switch (result['category']) {
      case 'AI':
        categoryColor = Color(0xFFB668F1);
        break;
      case 'General Knowledge':
        categoryColor = Color(0xFF709CF8);
        break;
      case 'Hardware':
        categoryColor = Color(0xFF97FFE2);
        break;
      case 'Grammar':
        categoryColor = Color(0xFF8DEAFD);
        break;
      default:
        categoryColor = Colors.white.withOpacity(0.15);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Name
              Text(
                result['category'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: difficultyColor, width: 1),
                ),
                child: Text(
                  result['difficulty'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: difficultyColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                formattedTime,
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score Container
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 6),
                    Text(
                      'Score: ${result['score']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Flips Container
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flip, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      'Flips: ${result['flipCount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}