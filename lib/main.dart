// main.dart — ПЛОТНАЯ НАТИВНАЯ МОБИЛЬНАЯ КЛАВИАТУРА (ЧАСТЬ 1)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Flutter',
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      theme: ThemeData.dark(),
      home: const WordleScreen(),
    );
  }
}

class WordleScreen extends StatelessWidget {
  const WordleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WordleBody(),
    );
  }
}

class WordleBody extends StatefulWidget {
  const WordleBody({super.key});

  @override
  State<WordleBody> createState() => _WordleBodyState();
}

class _WordleBodyState extends State<WordleBody> {
  final Game _game = Game();
  final FocusNode _focusNode = FocusNode();
  bool _isDictionaryLoaded = false;

  @override
  void initState() {
    super.initState();
    _initGameData();
  }

  Future<void> _initGameData() async {
    await _game.loadDictionary();
    setState(() {
      _isDictionaryLoaded = true;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color _getTileColor(HitType type) {
    switch (type) {
      case HitType.hit: return Colors.green;
      case HitType.miss: return Colors.orange;
      case HitType.none: return Colors.grey.shade800;
    }
  }

  Color _getKeyColor(String key) {
    if (key == 'ENTER' || key == '⌫') return Colors.grey.shade700;
    if (!_game.isKeyUsed(key)) return Colors.grey.shade600;
    
    switch (_game.getKeyStatus(key)) {
      case HitType.hit: return Colors.green;
      case HitType.miss: return Colors.orange;
      case HitType.none: return Colors.grey.shade900;
    }
  }

  void _handleKeyPress(String key) {
    if (_game.isGameOver || !_isDictionaryLoaded) return;

    setState(() {
      if (key == 'ENTER') {
        bool valid = _game.checkGuess();
        if (!valid && !_game.isGameOver) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Not in word list!', 
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70),
                textAlign: CenterHtmlText.center,
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating, 
              width: 200, 
              backgroundColor: const Color(0xFF9E3D3D), 
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else if (_game.isGameOver) {
          _showResultDialog();
        }
      } else if (key == '⌫' || key == 'BACKSPACE') {
        _game.removeLetter();
      } else {
        if (RegExp(r'^[A-Z]$').hasMatch(key.toUpperCase())) {
          _game.addLetter(key.toUpperCase());
        }
      }
    });
  }

  void _handlePhysicalKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyLabel = event.logicalKey.keyLabel.toUpperCase();

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleKeyPress('ENTER');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _handleKeyPress('⌫');
      } else if (keyLabel.length == 1) {
        _handleKeyPress(keyLabel);
      }
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(_game.isWon ? '🎉 Victory!' : '😔 Game Over'),
          content: Text(_game.isWon 
            ? 'You guessed the word correctly!' 
            : 'Out of tries. The correct word was: ${_game.correctWord}'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _game.reset();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Play Again', style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);

    if (!_isDictionaryLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 450; 

    // ПК-ВЕРСИЯ: НАШ ПЕРВОНАЧАЛЬНЫЙ НЕПРИКОСНОВЕННЫЙ COLUMN ПО ЦЕНТРУ
    if (!isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('BIRDLE (WORDLE)'), centerTitle: true),
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handlePhysicalKey,
          child: SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(), 
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.0, 
                          ),
                          itemCount: 30,
                          itemBuilder: (context, index) => _buildGridTile(index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 540.0,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: [
                          _buildKeyboardRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'], 56.0, false),
                          const SizedBox(height: 6),
                          _buildKeyboardRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'], 56.0, false),
                          const SizedBox(height: 6),
                          _buildKeyboardRow(['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'], 56.0, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // МОБИЛЬНАЯ ВЕРСИЯ: СЕТКА СВЕРХУ, ПЛОТНАЯ НАТИВНАЯ КЛАВИАТУРА СНИЗУ
    return Scaffold(
      appBar: AppBar(title: const Text('BIRDLE (WORDLE)'), centerTitle: true),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handlePhysicalKey,
        child: SafeArea(
          child: Column(
            children: [
              // ЧАСТЬ 1: ИГРОВАЯ СЕТКА (МЫ ЕЁ НЕ ТРОГАЕМ И НЕ ИЗМЕНЯЕМ)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: FittedBox( 
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter, 
                    child: SizedBox( 
                      width: 340, 
                      height: 410, 
                      child: GridView.builder(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(), 
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.0, 
                        ),
                        itemCount: 30,
                        itemBuilder: (context, index) => _buildGridTile(index),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 0),

              // ЧАСТЬ 2: НАТИВНАЯ МОБИЛЬНАЯ КЛАВИАТУРА (Высота кнопок 76.0, зазоры сжаты)
              Container(
                width: screenWidth,
                padding: const EdgeInsets.only(bottom: 12.0, left: 2.0, right: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, 
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    _buildKeyboardRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'], 76.0, true),
                    const SizedBox(height: 4), 
                    _buildKeyboardRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'], 76.0, true),
                    const SizedBox(height: 4),
                    _buildKeyboardRow(['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'], 76.0, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildGridTile(int index) {
    int rowIndex = index ~/ 5;
    int colIndex = index % 5;

    String displayChar = "";
    Color tileColor = Colors.transparent;
    Color borderColor = Colors.grey.shade600;

    if (rowIndex < _game.guesses.length) {
      var letter = _game.guesses[rowIndex].letters[colIndex];
      displayChar = letter.char;
      tileColor = _getTileColor(letter.type);
      borderColor = Colors.transparent;
    } else if (rowIndex == _game.guesses.length) {
      if (colIndex < _game.currentGuess.length) {
        displayChar = _game.currentGuess[colIndex];
        borderColor = Colors.white;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        displayChar,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, double keyHeight, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        final isSpecial = key == 'ENTER' || key == '⌫';
        
        Widget button = Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 0.6 : 2.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, 
              backgroundColor: _getKeyColor(key),
              minimumSize: Size(isMobile ? 0 : (isSpecial ? 82.0 : 42.0), keyHeight), 
              maximumSize: Size(isMobile ? double.infinity : (isSpecial ? 102.0 : 62.0), keyHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () => _handleKeyPress(key),
            child: Text(
              key,
              style: TextStyle(
                fontSize: isSpecial ? (isMobile ? 10 : 12) : (isMobile ? 16 : 17), 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );

        if (isMobile) {
          return Expanded(
            flex: isSpecial ? 15 : 10, 
            child: button,
          );
        } else {
          return button;
        }
      }).toList(),
    );
  }
}

class CenterHtmlText {
  static const TextAlign center = TextAlign.center;
}
