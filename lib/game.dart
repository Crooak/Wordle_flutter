// game.dart — ЛОГИКА С ДВУМЯ РАЗДЕЛЬНЫМИ СЛОВАРЯМИ (ОТВЕТЫ И ВВОД)
import 'dart:math';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart' show rootBundle; 

enum HitType { none, miss, hit }

class Letter {
  final String char;
  final HitType type;
  const Letter({required this.char, required this.type});
}

class Word {
  final List<Letter> letters;
  const Word(this.letters);
  bool get isCorrect => letters.every((l) => l.type == HitType.hit);
}

class Game {
  List<String> _validGuesses = []; //10 000+ слов для проверки наобум
  List<String> _secretWords = [];  //2 315 каноничных слов для загадывания
  
  late String correctWord; 
  List<Word> guesses = []; 
  String currentGuess = "";

  // Асинхронная одновременная загрузка обоих файлов
  Future<void> loadDictionary() async {
    try {
      // 1. Загружаем и парсим базу разрешенных слов (разделение по переносу строки)
      String validContent = await rootBundle.loadString('assets/words.txt');
      _validGuesses = validContent
          .split(RegExp(r'\r?\n'))
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      // 2. Загружаем и парсим базу секретных ответов (2 315 слов)
      String secretContent = await rootBundle.loadString('assets/secrets.txt');
      _secretWords = secretContent
          .split(RegExp(r'\r?\n'))
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      // Подстраховка на случай, если файлы оказались пустыми
      if (_validGuesses.isEmpty) _validGuesses = ["FLUTT", "BUILD", "STATE"];
      if (_secretWords.isEmpty) _secretWords = ["FLUTT", "BUILD", "STATE"];

      _selectRandomWord();
    } catch (e) {
      debugPrint("Критическая ошибка загрузки словарей: $e");
      // Аварийный дефолтный режим
      _validGuesses = ["FLUTT", "BUILD", "STATE", "PHONE", "SMART"];
      _secretWords = ["FLUTT", "BUILD", "STATE", "PHONE", "SMART"];
      _selectRandomWord();
    }
  }

  // Выбор слова происходит из пула 2 315 секретных слов ответов
  void _selectRandomWord() {
    if (_secretWords.isEmpty) return;
    final random = Random();
    correctWord = _secretWords[random.nextInt(_secretWords.length)];
    debugPrint("ЗАГАДАННОЕ СЛОВО НА ТЕКУЩИЙ МАТЧ: $correctWord");
  }

  bool get isWon => guesses.isNotEmpty && guesses.last.isCorrect;
  bool get isLost => guesses.length >= 6 && !isWon;
  bool get isGameOver => isWon || isLost;

  void reset() {
    guesses = []; 
    currentGuess = "";
    _selectRandomWord(); // Берет новое случайное слово из secrets.txt
  }

  void addLetter(String char) {
    if (isGameOver) return;
    if (currentGuess.length < 5 && guesses.length < 6) {
      currentGuess += char.toUpperCase();
    }
  }

  void removeLetter() {
    if (isGameOver) return;
    if (currentGuess.isNotEmpty) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
    }
  }

  bool checkGuess() {
    if (isGameOver || currentGuess.length != 5) return false;

    // Сверяем введенный наобум вариант со всеми 10 000+ легальными словами
    if (!_validGuesses.contains(currentGuess) && !_secretWords.contains(currentGuess)) {
      return false; 
    }

    List<Letter> checkedLetters = List.filled(5, const Letter(char: "", type: HitType.none));
    List<bool> wordLettersUsed = List.filled(5, false);

    for (int i = 0; i < 5; i++) {
      if (currentGuess[i] == correctWord[i]) {
        checkedLetters[i] = Letter(char: currentGuess[i], type: HitType.hit);
        wordLettersUsed[i] = true;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (checkedLetters[i].char.isNotEmpty) continue; 

      String guessChar = currentGuess[i];
      HitType type = HitType.none;

      for (int j = 0; j < 5; j++) {
        if (!wordLettersUsed[j] && correctWord[j] == guessChar) {
          type = HitType.miss;
          wordLettersUsed[j] = true;
          break;
        }
      }

      checkedLetters[i] = Letter(char: guessChar, type: type);
    }

    guesses.add(Word(checkedLetters));
    currentGuess = "";
    return true;
  }

  HitType getKeyStatus(String char) {
    HitType bestStatus = HitType.none;
    bool found = false;

    for (var guess in guesses) {
      for (var letter in guess.letters) {
        if (letter.char == char.toUpperCase()) {
          found = true;
          if (letter.type == HitType.hit) return HitType.hit;
          if (letter.type == HitType.miss) bestStatus = HitType.miss;
        }
      }
    }
    return found ? (bestStatus == HitType.miss ? HitType.miss : HitType.none) : HitType.none;
  }
  
  bool isKeyUsed(String char) {
    return guesses.any((g) => g.letters.any((l) => l.char == char.toUpperCase()));
  }
}
