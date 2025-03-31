import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const VirtualAquariumApp());
}

class VirtualAquariumApp extends StatelessWidget {
  const VirtualAquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AquariumScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Fish {
  final Color color;
  final double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed})
      : position = Offset(Random().nextDouble() * 250, Random().nextDouble() * 250),
        direction = Offset(
          Random().nextDouble() * 2 - 1,
          Random().nextDouble() * 2 - 1,
        );
}

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Fish> fishList = [];
  Color selectedColor = Colors.orange;
  double selectedSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {
          for (var fish in fishList) {
            Offset newPos = fish.position + fish.direction * fish.speed;
            if (newPos.dx < 0 || newPos.dx > 270) fish.direction = Offset(-fish.direction.dx, fish.direction.dy);
            if (newPos.dy < 0 || newPos.dy > 270) fish.direction = Offset(fish.direction.dx, -fish.direction.dy);
            fish.position += fish.direction * fish.speed;
          }
        });
      })..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Virtual Aquarium")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Stack(
                children: fishList.map((fish) {
                  return Positioned(
                    left: fish.position.dx,
                    top: fish.position.dy,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: fish.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addFish,
                  child: const Text("Add Fish"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Save to SQLite
                  },
                  child: const Text("Save Settings"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Speed"),
                      Slider(
                        value: selectedSpeed,
                        min: 0.5,
                        max: 5.0,
                        onChanged: (value) {
                          setState(() => selectedSpeed = value);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Color"),
                      DropdownButton<Color>(
                        value: selectedColor,
                        items: <Color>[
                          Colors.orange,
                          Colors.green,
                          Colors.purple,
                          Colors.red
                        ].map((Color color) {
                          return DropdownMenuItem<Color>(
                            value: color,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Colors.black12),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (Color? newColor) {
                          if (newColor != null) {
                            setState(() => selectedColor = newColor);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}