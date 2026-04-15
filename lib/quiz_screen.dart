import 'package:flutter/material.dart';
import 'difficulty_screen.dart';
import 'bottom_nav_bar.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'AI', 'icon': '🤖', 'color': Color(0xFFC76CFF)},
    {'name': 'Grammar', 'icon': '📝', 'color': Color(0xFFDC9FFA)},
    {'name': 'General Knowledge', 'icon': '📚', 'color': Color(0xFF55A4EF)},
    {'name': 'Hardware', 'icon': '💻', 'color': Color(0xFF8ABFEF)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A72D3),
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
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                            ),
                          ),
                          Expanded(
                            child: GlowingTextWithUnderline(
                              text: 'Quiz Challenge',
                            ),
                          ),
                          SizedBox(width: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Choose a Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Categories List with Animations
                      Expanded(
                        child: ListView.separated(
                          itemCount: categories.length,
                          separatorBuilder: (context, index) => SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return FloatingCategoryCard(
                              index: index,
                              categoryName: categories[index]['name'] as String,
                              icon: categories[index]['icon'] as String,
                              cardColor: categories[index]['color'] as Color,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              BottomNavBar(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== FLOATING CATEGORY ==========
class FloatingCategoryCard extends StatefulWidget {
  final int index;
  final String categoryName;
  final String icon;
  final Color cardColor;

  const FloatingCategoryCard({
    super.key,
    required this.index,
    required this.categoryName,
    required this.icon,
    required this.cardColor,
  });

  @override
  State<FloatingCategoryCard> createState() => _FloatingCategoryCardState();
}

class _FloatingCategoryCardState extends State<FloatingCategoryCard> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(milliseconds: 2000 + (widget.index * 200)),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4, end: 14).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color darkerColor = Color.alphaBlend(
      Colors.black.withOpacity(0.3),
      widget.cardColor,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: darkerColor.withOpacity(0.8),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DifficultyScreen(categoryName: widget.categoryName),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: darkerColor,
                    width: 3,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.icon, style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '3 difficulty levels',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========== GLOWING TEXT WITH UNDERLINE ==========
class GlowingTextWithUnderline extends StatefulWidget {
  final String text;

  const GlowingTextWithUnderline({super.key, required this.text});

  @override
  State<GlowingTextWithUnderline> createState() => _GlowingTextWithUnderlineState();
}

class _GlowingTextWithUnderlineState extends State<GlowingTextWithUnderline> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 10 + (8 * _glowAnimation.value),
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Container(
              width: 160,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white,
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}