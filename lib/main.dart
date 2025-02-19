import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 20;
  int hungerLevel = 50;
  late TextEditingController _nameController;
  late Timer _hungerTimer;
  late Timer _winConditionTimer;
  bool _isGameOver = false;
  bool _hasWon = false;
  int happinessAboveThresholdDuration = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startHungerTimer();
    _startWinConditionTimer();
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel >= 100) {
          happinessLevel = (happinessLevel - 20).clamp(0, 100);
        }
        _checkLossCondition();
      });
    });
  }

  void _startWinConditionTimer() {
    _winConditionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (happinessLevel > 80) {
        happinessAboveThresholdDuration++;
        if (happinessAboveThresholdDuration >= 30) {
          setState(() {
            _hasWon = true;
            _hungerTimer.cancel();
            _winConditionTimer.cancel();
          });
        }
      } else {
        happinessAboveThresholdDuration = 0;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hungerTimer.cancel();
    _winConditionTimer.cancel();
    super.dispose();
  }

  void _playWithPet() {
    if (_isGameOver || _hasWon) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  void _feedPet() {
    if (_isGameOver || _hasWon) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    _checkLossCondition();
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
    _checkLossCondition();
  }

  void _checkLossCondition() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      setState(() {
        _isGameOver = true;
        _hungerTimer.cancel();
        _winConditionTimer.cancel();
      });
    }
  }

  void _submitName() {
    setState(() {
      petName = _nameController.text;
    });
  }

  String _getPetImage() {
    if (happinessLevel > 70) {
      return 'assets/happy_dog.png';
    } else if (happinessLevel >= 50) {
      return 'assets/normal_dog.png';
    } else if (happinessLevel >= 30) {
      return 'assets/sad_dog.png';
    } else {
      return 'assets/angry_dog.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Name: $petName',
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(_getPetImage()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                _isGameOver
                    ? 'Game Over! 😢'
                    : _hasWon
                        ? 'You Win! 🎉'
                        : 'Happiness Level: $happinessLevel%',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Hunger Level: $hungerLevel%',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _playWithPet,
                child: const Text('Play with Your Pet'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: const Text('Feed Your Pet'),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Pet Name',
                  ),
                  onSubmitted: (_) => _submitName(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}