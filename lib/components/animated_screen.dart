import 'package:flutter/material.dart';
import 'package:music/pages/login.dart';
import 'package:o3d/o3d.dart';
import 'dart:math';
import 'dart:async';

class Animated3DScreen extends StatefulWidget {
  @override
  _Animated3DScreenState createState() => _Animated3DScreenState();
}

class _Animated3DScreenState extends State<Animated3DScreen>
    with TickerProviderStateMixin {
  O3DController controller = O3DController();
  List<FloatingMessage> floatingMessages = [];
  Timer? messageTimer;
  Random random = Random();

  // Messages à afficher aléatoirement
  List<String> messages = [
    "Vivez un moment... ✨",
    "Inoubliable... 🎉",
    "Fantastique! 🚀",
    "Génial! 💫",
    "Superbe! 🌟",
    "Parfait! 💎",
    "Avec Z-music! 🔥",
    "Bravo! 👏",
    "Wow! 😍",
    "Amazing! ⭐",
  ];

  @override
  void initState() {
    super.initState();
    startFloatingMessages();
  }

  void startFloatingMessages() {
    messageTimer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (floatingMessages.length < 6) {
        // Max 6 messages simultanés
        addFloatingMessage();
      }
    });
  }

  void addFloatingMessage() {
    final message = messages[random.nextInt(messages.length)];
    final animationController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    final floatingMessage = FloatingMessage(
      text: message,
      startX: random.nextDouble() * 0.8 + 0.1, // 10% à 90% de la largeur
      animationController: animationController,
      onComplete: () {
        setState(() {
          floatingMessages.removeWhere((msg) => msg.text == message);
        });
        animationController.dispose();
      },
    );

    setState(() {
      floatingMessages.add(floatingMessage);
    });

    animationController.forward();
  }

  @override
  void dispose() {
    messageTimer?.cancel();
    for (var message in floatingMessages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFF26C6DA),
              Color(0xFF00BCD4),
              Color(0xFF009688),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Layout principal
              Column(
                children: [
                  // Texte de bienvenue
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          'Bienvenue',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Découvrez l\'expérience avec Z-music',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        child: O3D(
                          src: 'assets/danse.glb',
                          controller: controller,
                          ar: false,
                          autoPlay: true,
                          autoRotate: false,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF009688),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Messages flottants par-dessus tout
              ...floatingMessages
                  .map((message) => FloatingMessageWidget(message: message))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingMessage {
  final String text;
  final double startX;
  final AnimationController animationController;
  final VoidCallback onComplete;

  FloatingMessage({
    required this.text,
    required this.startX,
    required this.animationController,
    required this.onComplete,
  });
}

class FloatingMessageWidget extends StatelessWidget {
  final FloatingMessage message;

  const FloatingMessageWidget({Key? key, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: message.animationController,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Position Y: du bas vers le haut
        final yPosition =
            screenHeight * (1.0 - message.animationController.value);

        // Opacité: 0 -> 1 -> 0
        double opacity;
        if (message.animationController.value < 0.4) {
          // Fade in (0 à 20%)
          opacity = message.animationController.value / 0.4;
        } else if (message.animationController.value < 0.6) {
          // Visible (20% à 80%)
          opacity = 1.0;
        } else {
          // Fade out (80% à 100%)
          opacity = (1.0 - message.animationController.value) / 0.2;
        }

        // Vérifier si l'animation est terminée
        if (message.animationController.value == 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            message.onComplete();
          });
        }

        return Positioned(
          left: screenWidth * message.startX,
          top: yPosition - 100, // Ajuster pour commencer en bas
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF009688),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
