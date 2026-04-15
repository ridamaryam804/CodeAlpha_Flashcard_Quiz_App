# Flashcard Quiz App
A beautiful and interactive **Flashcard Quiz App** built with **Flutter** to help users learn through flashcards. Users can quiz themselves across multiple categories and difficulty levels, track their progress, and manage their own flashcards.

## Features
###  Categories
**AI** - Artificial Intelligence concepts
**Grammar** - English grammar rules
**General Knowledge** - World facts and trivia
**Hardware** - Computer hardware components

### Difficulty Levels
**Easy** - Basic questions for beginners
**Medium** - Intermediate level questions
**Hard** - Advanced challenging questions

### Flashcard Features
Question on front, answer on back with flip animation
   **Add** new flashcards
  **Edit** existing flashcards
  **Delete** flashcards
   Next/Previous navigation between cards

   ### Quiz Features
**30-second timer** for each question
**Submit Answer** button to check your response
**Show Question** button to reveal the answer
**Score tracking** (correct/wrong count)
**Flip count tracking** to monitor how many times you flipped cards

### Smart Learning System
**Spaced Repetition** -Wrong answers are saved for practice
**Weak Cards Practice** - Review incorrectly answered cards at the end of quiz
**Progress Tracking** - All quiz results are saved


##  Technologies Used

| Technology | Purpose |
|------------|---------|
| **Flutter** | UI framework |
| **Dart** | Programming language |
| **Shared Preferences** | Local data storage |

##  Getting Started
Follow these steps to run the project on your local machine.

### Prerequisites
Make sure you have the following installed:

 **Flutter SDK** (latest version)
**Dart SDK** (comes with Flutter)
**Android Studio** or **VS Code**
 **Git** (for version control)

### Installation Steps

#### 1.Clone the Repository
##   2.Navigate to Project Directory
 cd flashcard_quiz_app
##   3.Get Dependencies
  flutter pub get
##   4.Run the App
   flutter run
## Run on Specific Device
# Run on Android
flutter run -d android
# Run on iOS (Mac only)
flutter run -d ios
# Run on Chrome (Web)
flutter run -d chrome

## Building APK
To generate an APK file for Android:  flutter build apk --release

## How to Use
Tap "Slide to start" on the welcome screen
Select a category (AI, Grammar, GK, or Hardware)
Choose a difficulty level (Easy, Medium, or Hard)
Answer questions within 30 seconds
Tap "Submit Answer" to check your response
Use "Show Question" to reveal the answer
Navigate with Next/Previous arrows

## Managing Flashcards
Tap the "+" (Plus) button on the quiz screen
Enter Question and Answer
Tap "Add Card" to save
To edit, tap the  edit icon on any flashcard
To delete, tap the  delete icon on any flashcard

## Viewing Results
Tap "Results" in the bottom navigation bar
View all your past quiz attempts
See score, difficulty, date, and time
