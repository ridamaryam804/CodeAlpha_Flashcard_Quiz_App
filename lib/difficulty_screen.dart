import 'package:flutter/material.dart';
import 'flashcard_quiz.dart';
import 'bottom_nav_bar.dart';

class DifficultyScreen extends StatefulWidget {
  final String categoryName;

  const DifficultyScreen({super.key, required this.categoryName});

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> with TickerProviderStateMixin {
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late Animation<double> _floatAnimation1;
  late Animation<double> _floatAnimation2;
  late Animation<double> _floatAnimation3;

  @override
  void initState() {
    super.initState();

    _floatController1 = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation1 = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController1, curve: Curves.easeInOut),
    );

    _floatController2 = AnimationController(
      duration: Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation2 = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController2, curve: Curves.easeInOut),
    );

    _floatController3 = AnimationController(
      duration: Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation3 = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController3, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Top Section with Border Container
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // ❌ Arrow removed - No back button arrow
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 12),

                        // "Select Difficulty" inside same border
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🤔',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Select Difficulty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '🤔',
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Difficulty Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      // Easy Card
                      AnimatedBuilder(
                        animation: _floatAnimation1,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation1.value),
                            child: _buildDifficultyCard(
                              'Easy',
                              '😊',
                              Color(0xFFD0F4E0),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 14),

                      // Medium Card
                      AnimatedBuilder(
                        animation: _floatAnimation2,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation2.value),
                            child: _buildDifficultyCard(
                              'Medium',
                              '😐',
                              Color(0xFFA8DEFA),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 14),

                      // Hard Card
                      AnimatedBuilder(
                        animation: _floatAnimation3,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation3.value),
                            child: _buildDifficultyCard(
                              'Hard',
                              '😰',
                              Color(0xFFE8C0FC),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Footer
              BottomNavBar(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
      String level,
      String emoji,
      Color cardColor,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardQuizScreen(
              categoryName: widget.categoryName,
              difficulty: level,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 34),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}