import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'result_screen.dart';
import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import 'shared_prefs_helper.dart';
import 'dart:async';

class FlashcardQuizScreen extends StatefulWidget {
  final String categoryName;
  final String difficulty;

  const FlashcardQuizScreen({
    super.key,
    required this.categoryName,
    required this.difficulty,
  });

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  List<Map<String, String>> flashcards = [];
  List<Map<String, String>> originalFlashcards = [];
  List<int> weakCardsIndices = [];

  int currentIndex = 0;
  bool isFlipped = false;
  TextEditingController answerController = TextEditingController();
  int correctCount = 0;
  int wrongCount = 0;
  int flipCount = 0;

  // Timer variables
  int _timeLeft = 30;
  Timer? _timer;
  bool _isTimerRunning = false;

  // Loading state
  bool isLoading = true;

  final LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF63B1F8), Color(0xFF97CBFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _stopTimer();
    answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _timeLeft = 30;
    _isTimerRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && mounted) {
        setState(() {
          _timeLeft--;
        });
      } else if (_timeLeft == 0 && mounted) {
        _stopTimer();
        _showTimeOutPopup();
      }
    });
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
  }

  void _showTimeOutPopup() {
    setState(() {
      wrongCount++;
      weakCardsIndices.add(currentIndex);
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, color: Colors.white, size: 50),
              SizedBox(height: 15),
              Text('Time\'s Up!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('The answer was: ${flashcards[currentIndex]['answer']}', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextCard();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
                child: Text('Next Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadFlashcards() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, String>> savedCards = await SharedPrefsHelper.loadFlashcards(
        widget.categoryName,
        widget.difficulty
    );

    if (savedCards.isNotEmpty) {
      setState(() {
        flashcards = savedCards;
        originalFlashcards = List.from(savedCards);
      });
    } else {
      List<Map<String, String>> defaultCards = _getDefaultFlashcards();
      setState(() {
        flashcards = defaultCards;
        originalFlashcards = List.from(defaultCards);
      });
      await SharedPrefsHelper.saveFlashcards(widget.categoryName, widget.difficulty, defaultCards);
    }

    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, String>> _getDefaultFlashcards() {
    if (widget.categoryName == 'AI') {
      if (widget.difficulty == 'Easy') return _getAIEasy();
      if (widget.difficulty == 'Medium') return _getAIMedium();
      return _getAIHard();
    }
    if (widget.categoryName == 'Grammar') {
      if (widget.difficulty == 'Easy') return _getGrammarEasy();
      if (widget.difficulty == 'Medium') return _getGrammarMedium();
      return _getGrammarHard();
    }
    if (widget.categoryName == 'General Knowledge') {
      if (widget.difficulty == 'Easy') return _getGKEasy();
      if (widget.difficulty == 'Medium') return _getGKMedium();
      return _getGKHard();
    }
    if (widget.categoryName == 'Hardware') {
      if (widget.difficulty == 'Easy') return _getHardwareEasy();
      if (widget.difficulty == 'Medium') return _getHardwareMedium();
      return _getHardwareHard();
    }
    return [{'question': 'Sample Question?', 'answer': 'Sample Answer'}];
  }

  void _practiceWeakCards() {
    if (weakCardsIndices.isNotEmpty) {
      List<Map<String, String>> weakCards = [];
      for (int index in weakCardsIndices) {
        if (index < originalFlashcards.length) {
          weakCards.add(originalFlashcards[index]);
        }
      }
      if (weakCards.isNotEmpty) {
        setState(() {
          flashcards = weakCards;
          currentIndex = 0;
          isFlipped = false;
          answerController.clear();
          weakCardsIndices.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Practicing ${weakCards.length} weak cards!'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _addNewCard(String question, String answer) async {
    setState(() {
      flashcards.add({'question': question, 'answer': answer});
      originalFlashcards.add({'question': question, 'answer': answer});
    });
    await SharedPrefsHelper.addFlashcard(
        widget.categoryName,
        widget.difficulty,
        {'question': question, 'answer': answer}
    );
  }

  // Edit Card Function
  void _editCard(int index, String newQuestion, String newAnswer) async {
    setState(() {
      flashcards[index]['question'] = newQuestion;
      flashcards[index]['answer'] = newAnswer;
      originalFlashcards[index]['question'] = newQuestion;
      originalFlashcards[index]['answer'] = newAnswer;
    });

    await SharedPrefsHelper.saveFlashcards(widget.categoryName, widget.difficulty, flashcards);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card edited successfully!'), backgroundColor: Colors.green),
    );
  }

  //  Delete Card Function
  void _deleteCard(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Card'),
        content: Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                flashcards.removeAt(index);
                originalFlashcards.removeAt(index);

                if (currentIndex >= flashcards.length && flashcards.isNotEmpty) {
                  currentIndex = flashcards.length - 1;
                }
                if (currentIndex < 0 && flashcards.isNotEmpty) {
                  currentIndex = 0;
                }
                if (flashcards.isEmpty) {
                  currentIndex = 0;
                }
                isFlipped = false;
                answerController.clear();
              });

              await SharedPrefsHelper.saveFlashcards(widget.categoryName, widget.difficulty, flashcards);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Card deleted!'), backgroundColor: Colors.red),
              );

              if (flashcards.isEmpty) {
                Navigator.pop(context);
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      flipCount++;
    });
  }

  void _nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
        answerController.clear();
      });
      _startTimer();
    } else {
      _stopTimer();
      if (weakCardsIndices.isNotEmpty) {
        _showWeakCardsPopup();
      } else {
        _showCompletionPopup();
      }
    }
  }

  void _showWeakCardsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 50),
              SizedBox(height: 15),
              Text('Practice Weak Cards?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('You have ${weakCardsIndices.length} cards to review!', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _practiceWeakCards();
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
                      child: Text('Practice'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCompletionPopup();
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white)),
                      child: Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
        answerController.clear();
      });
      _startTimer();
    }
  }

  void _showWrongAnswerPopup() {
    setState(() {
      wrongCount++;
      weakCardsIndices.add(currentIndex);
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, color: Colors.white, size: 50),
                    SizedBox(height: 15),
                    Text('Wrong Answer!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Correct: ${flashcards[currentIndex]['answer']}', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                      child: Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCompletionPopup() async {
    String scoreText = '$correctCount/${flashcards.length}';

    await SharedPrefsHelper.saveQuizStats(
        widget.categoryName,
        widget.difficulty,
        correctCount,
        flashcards.length,
        flipCount
    );

    addQuizResult(widget.categoryName, widget.difficulty, scoreText, flipCount);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFF6DA2), Color(0xFF5FABF3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 25, spreadRadius: 3)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 600),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double scaleValue, child) => Transform.scale(scale: scaleValue, child: Icon(Icons.emoji_events, color: Colors.yellow, size: 70)),
                    ),
                    SizedBox(height: 15),
                    Text('Congratulations! 🎉', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Text('You have completed all questions!', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 10),
                    Text('Score: $scoreText', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow)),
                    SizedBox(height: 10),
                    Text('Total Flips: $flipCount', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFFFF6DA2), padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: Text('Back to Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkAnswer() {
    String userAnswer = answerController.text.trim().toLowerCase();
    String correctAnswer = flashcards[currentIndex]['answer']!.toLowerCase();

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please type an answer!'), backgroundColor: Colors.orange));
      return;
    }

    if (userAnswer == correctAnswer) {
      setState(() {
        correctCount++;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Correct!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
      answerController.clear();
      _nextCard();
    } else {
      setState(() {
        wrongCount++;
        weakCardsIndices.add(currentIndex);
      });
      _showWrongAnswerPopup();
    }
  }

  void _showQuestion() {
    setState(() {
      isFlipped = false;
      flipCount++;
    });
  }

  // ========== FLASHCARD DATA ==========
  List<Map<String, String>> _getAIEasy() => [
    {'question': 'What is AI?', 'answer': 'Artificial Intelligence'},
    {'question': 'What is ML?', 'answer': 'Machine Learning'},
    {'question': 'What is NLP?', 'answer': 'Natural Language Processing'},
    {'question': 'What is Neural Network?', 'answer': 'Deep Learning'},
    {'question': 'What is ChatGPT?', 'answer': 'AI Chatbot'},
    {'question': 'What is Computer Vision?', 'answer': 'Image Recognition'},
    {'question': 'What is Data Science?', 'answer': 'Data Analysis'},
    {'question': 'What is Algorithm?', 'answer': 'Step-by-step'},
    {'question': 'What is Training Data?', 'answer': 'Learning Examples'},
    {'question': 'What is Model?', 'answer': 'AI System'},
  ];

  List<Map<String, String>> _getAIMedium() => [
    {'question': 'What is Deep Learning?', 'answer': 'Neural Networks'},
    {'question': 'What is Supervised Learning?', 'answer': 'Labeled Data'},
    {'question': 'What is Unsupervised Learning?', 'answer': 'Unlabeled Data'},
    {'question': 'What is Reinforcement Learning?', 'answer': 'Reward System'},
    {'question': 'What is TensorFlow?', 'answer': 'Google Library'},
    {'question': 'What is PyTorch?', 'answer': 'Facebook Library'},
    {'question': 'What is Overfitting?', 'answer': 'Too Complex'},
    {'question': 'What is Underfitting?', 'answer': 'Too Simple'},
    {'question': 'What is Backpropagation?', 'answer': 'Error Correction'},
    {'question': 'What is Activation Function?', 'answer': 'Non-linearity'},
  ];

  List<Map<String, String>> _getAIHard() => [
    {'question': 'What is Transformer?', 'answer': 'Attention Model'},
    {'question': 'What is GAN?', 'answer': 'Generative Network'},
    {'question': 'What is LSTM?', 'answer': 'Long Short Term'},
    {'question': 'What is CNN?', 'answer': 'Convolutional Network'},
    {'question': 'What is RNN?', 'answer': 'Recurrent Network'},
    {'question': 'What is BERT?', 'answer': 'Google Model'},
    {'question': 'What is GPT?', 'answer': 'Generative Pretrained'},
    {'question': 'What is LLM?', 'answer': 'Large Language Model'},
    {'question': 'What is Fine-tuning?', 'answer': 'Adjust Model'},
    {'question': 'What is Transfer Learning?', 'answer': 'Reuse Model'},
  ];

  List<Map<String, String>> _getGrammarEasy() => [
    {'question': 'What is a Noun?', 'answer': 'Person Place Thing'},
    {'question': 'What is a Verb?', 'answer': 'Action Word'},
    {'question': 'What is an Adjective?', 'answer': 'Describes Noun'},
    {'question': 'What is an Adverb?', 'answer': 'Describes Verb'},
    {'question': 'What is a Pronoun?', 'answer': 'Replaces Noun'},
    {'question': 'What is a Preposition?', 'answer': 'Position Word'},
    {'question': 'What is a Conjunction?', 'answer': 'Connects Words'},
    {'question': 'What is an Interjection?', 'answer': 'Exclamation Word'},
    {'question': 'What is a Sentence?', 'answer': 'Complete Thought'},
    {'question': 'What is a Paragraph?', 'answer': 'Group Sentences'},
  ];

  List<Map<String, String>> _getGrammarMedium() => [
    {'question': 'What is Past Tense?', 'answer': 'Already Happened'},
    {'question': 'What is Present Tense?', 'answer': 'Happening Now'},
    {'question': 'What is Future Tense?', 'answer': 'Will Happen'},
    {'question': 'What is Active Voice?', 'answer': 'Subject Acts'},
    {'question': 'What is Passive Voice?', 'answer': 'Subject Receives'},
    {'question': 'What is a Clause?', 'answer': 'Has Subject Verb'},
    {'question': 'What is a Phrase?', 'answer': 'No Subject Verb'},
    {'question': 'What is a Comma?', 'answer': 'Pause Mark'},
    {'question': 'What is a Period?', 'answer': 'End Mark'},
    {'question': 'What is Capitalization?', 'answer': 'Start Sentence'},
  ];

  List<Map<String, String>> _getGrammarHard() => [
    {'question': 'What is Subjunctive Mood?', 'answer': 'Hypothetical Situations'},
    {'question': 'What is Gerund?', 'answer': 'Verb as Noun'},
    {'question': 'What is Infinitive?', 'answer': 'To + Verb'},
    {'question': 'What is Participle?', 'answer': 'Verb as Adjective'},
    {'question': 'What is Conditional?', 'answer': 'If-Then Statement'},
    {'question': 'What is Relative Clause?', 'answer': 'Describes Noun'},
    {'question': 'What is Appositive?', 'answer': 'Renames Noun'},
    {'question': 'What is Ellipsis?', 'answer': 'Omitted Words'},
    {'question': 'What is Parallelism?', 'answer': 'Same Structure'},
    {'question': 'What is Modifier?', 'answer': 'Adds Detail'},
  ];

  List<Map<String, String>> _getGKEasy() => [
    {'question': 'Capital of France?', 'answer': 'Paris'},
    {'question': 'Capital of Germany?', 'answer': 'Berlin'},
    {'question': 'Capital of Italy?', 'answer': 'Rome'},
    {'question': 'Capital of Spain?', 'answer': 'Madrid'},
    {'question': 'Capital of UK?', 'answer': 'London'},
    {'question': 'Capital of Japan?', 'answer': 'Tokyo'},
    {'question': 'Capital of China?', 'answer': 'Beijing'},
    {'question': 'Capital of India?', 'answer': 'New Delhi'},
    {'question': 'Capital of USA?', 'answer': 'Washington DC'},
    {'question': 'Capital of Canada?', 'answer': 'Ottawa'},
  ];

  List<Map<String, String>> _getGKMedium() => [
    {'question': 'Largest Ocean?', 'answer': 'Pacific Ocean'},
    {'question': 'Longest River?', 'answer': 'Nile River'},
    {'question': 'Highest Mountain?', 'answer': 'Mount Everest'},
    {'question': 'Largest Desert?', 'answer': 'Sahara Desert'},
    {'question': 'Largest Country?', 'answer': 'Russia'},
    {'question': 'Most Populous Country?', 'answer': 'China'},
    {'question': 'Smallest Country?', 'answer': 'Vatican City'},
    {'question': 'Fastest Animal?', 'answer': 'Cheetah'},
    {'question': 'Largest Animal?', 'answer': 'Blue Whale'},
    {'question': 'Tallest Animal?', 'answer': 'Giraffe'},
  ];

  List<Map<String, String>> _getGKHard() => [
    {'question': 'Who painted Mona Lisa?', 'answer': 'Leonardo da Vinci'},
    {'question': 'Who invented Light Bulb?', 'answer': 'Thomas Edison'},
    {'question': 'Who discovered Gravity?', 'answer': 'Isaac Newton'},
    {'question': 'Who wrote Romeo Juliet?', 'answer': 'Shakespeare'},
    {'question': 'Who painted Starry Night?', 'answer': 'Van Gogh'},
    {'question': 'Who invented Telephone?', 'answer': 'Alexander Bell'},
    {'question': 'Who discovered Penicillin?', 'answer': 'Alexander Fleming'},
    {'question': 'Who invented Printing Press?', 'answer': 'Gutenberg'},
    {'question': 'Who wrote Alchemist?', 'answer': 'Paulo Coelho'},
    {'question': 'Who painted Sistine Chapel?', 'answer': 'Michelangelo'},
  ];

  List<Map<String, String>> _getHardwareEasy() => [
    {'question': 'What is CPU?', 'answer': 'Central Processing Unit'},
    {'question': 'What is RAM?', 'answer': 'Random Access Memory'},
    {'question': 'What is ROM?', 'answer': 'Read Only Memory'},
    {'question': 'What is HDD?', 'answer': 'Hard Disk Drive'},
    {'question': 'What is SSD?', 'answer': 'Solid State Drive'},
    {'question': 'What is GPU?', 'answer': 'Graphics Processing Unit'},
    {'question': 'What is Motherboard?', 'answer': 'Main Circuit Board'},
    {'question': 'What is PSU?', 'answer': 'Power Supply Unit'},
    {'question': 'What is BIOS?', 'answer': 'Basic Input Output'},
    {'question': 'What is USB?', 'answer': 'Universal Serial Bus'},
  ];

  List<Map<String, String>> _getHardwareMedium() => [
    {'question': 'What is Cache Memory?', 'answer': 'Fast Memory'},
    {'question': 'What is Clock Speed?', 'answer': 'GHz Measurement'},
    {'question': 'What is Core?', 'answer': 'Processing Unit'},
    {'question': 'What is Thread?', 'answer': 'Execution Path'},
    {'question': 'What is PCIe?', 'answer': 'Expansion Slot'},
    {'question': 'What is DDR?', 'answer': 'Double Data Rate'},
    {'question': 'What is NVMe?', 'answer': 'Fast Storage'},
    {'question': 'What is SATA?', 'answer': 'Storage Interface'},
    {'question': 'What is HDMI?', 'answer': 'Video Output'},
    {'question': 'What is DisplayPort?', 'answer': 'Monitor Cable'},
  ];

  List<Map<String, String>> _getHardwareHard() => [
    {'question': 'What is ALU?', 'answer': 'Arithmetic Logic Unit'},
    {'question': 'What is CU?', 'answer': 'Control Unit'},
    {'question': 'What is Register?', 'answer': 'Small Storage'},
    {'question': 'What is Bus?', 'answer': 'Data Pathway'},
    {'question': 'What is Northbridge?', 'answer': 'CPU Memory Hub'},
    {'question': 'What is Southbridge?', 'answer': 'I/O Controller'},
    {'question': 'What is CMOS?', 'answer': 'BIOS Memory'},
    {'question': 'What is ECC RAM?', 'answer': 'Error Correcting'},
    {'question': 'What is RAID?', 'answer': 'Disk Array'},
    {'question': 'What is Firmware?', 'answer': 'Device Software'},
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E8BC4), Color(0xFF97CBFB), Color(0xFFFFC2D9), Color(0xFFFF99BE), Color(0xFFFD7BAC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text('Loading flashcards...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E8BC4), Color(0xFF97CBFB), Color(0xFFFFC2D9), Color(0xFFFF99BE), Color(0xFFFD7BAC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ========== TOP BORDER ==========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _stopTimer();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.categoryName} - ${widget.difficulty}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _timeLeft < 10 ? Colors.red.withOpacity(0.8) : Color(0xFF4E8BC4).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('$_timeLeft', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('$correctCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 2),
                          Text('/${flashcards.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
                          SizedBox(width: 8),
                          Text('$wrongCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCardScreen(
                                    onAddCard: _addNewCard,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF4E8BC4).withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ========== MAIN CONTENT ==========
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),


                      GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                          child: Container(
                            key: ValueKey(isFlipped),
                            width: double.infinity,
                            height: 280,
                            padding: EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              gradient: isFlipped ? blueGradient : LinearGradient(colors: [Colors.white, Colors.white]),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, spreadRadius: 2, offset: Offset(0, 5))],
                            ),
                            child: Stack(
                              children: [

                                Center(
                                  child: Text(
                                    isFlipped ? flashcards[currentIndex]['answer']! : flashcards[currentIndex]['question']!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isFlipped ? Colors.white : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit Icon
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditCardScreen(
                                                question: flashcards[currentIndex]['question']!,
                                                answer: flashcards[currentIndex]['answer']!,
                                                onEditCard: (newQuestion, newAnswer) {
                                                  _editCard(currentIndex, newQuestion, newAnswer);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.edit, color: Colors.blue, size: 22),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Delete Icon
                                      GestureDetector(
                                        onTap: () {
                                          _deleteCard(currentIndex);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.delete, color: Colors.red, size: 22),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      GestureDetector(
                        onTap: _flipCard,
                        child: Text(
                          isFlipped ? 'Tap card to see question' : 'Tap card to reveal answer',
                          style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
                        ),
                      ),

                      SizedBox(height: 25),

                      TextField(
                        controller: answerController,
                        decoration: InputDecoration(
                          hintText: 'Type your answer...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),

                      SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6DA2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minimumSize: Size(double.infinity, 0),
                        ),
                        child: Text('Submit Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: _previousCard,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(gradient: blueGradient, borderRadius: BorderRadius.circular(30)),
                              child: ElevatedButton(
                                onPressed: _showQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text('Show Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: _nextCard,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                              child: Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              BottomNavBar(currentIndex: 1),
            ],
          ),
        ),
      ),
    );
  }
}