import 'package:flutter/material.dart';
import 'package:music/services/auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:o3d/o3d.dart';
import 'package:music/pages/acceuil.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> with TickerProviderStateMixin {
  O3DController controller = O3DController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Animation controllers pour la page
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _formController;

  // Animations pour le modèle 3D
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  // Animations pour le formulaire
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _formScaleAnimation;

  // Messages flottants
  List<FloatingMessage> floatingMessages = [];
  Timer? messageTimer;
  Random random = Random();
  GlobalKey _modelKey = GlobalKey();

  bool _show3DModel = false;
  bool _showForm = false;

  // Messages à afficher aléatoirement
  List<String> messages = [
    "Bienvenue! ✨",
    "Connectez-vous! 🚀",
    "Sécurisé! 🔒",
    "Rapide! ⚡",
    "Moderne! 💫",
    "Élégant! 🌟",
    "Innovant! 💎",
    "Fluide! 🎯",
    "Cool! 😎",
    "Top! 👌",
  ];

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _formController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animations pour le modèle 3D
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Animations pour le formulaire
    _formSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _formScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutBack),
    );

    // Démarrer la séquence d'animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Attendre 2 secondes
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      // 2. Afficher et animer le modèle 3D
      setState(() {
        _show3DModel = true;
      });
      _fadeController.forward();
      _bounceController.forward();

      // 3. Démarrer les messages flottants après l'apparition du modèle
      await Future.delayed(Duration(milliseconds: 600));
      if (mounted) {
        startFloatingMessages();
      }

      // 4. Afficher le formulaire
      await Future.delayed(Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _showForm = true;
        });
        _formController.forward();
      }
    }
  }

  void startFloatingMessages() {
    messageTimer = Timer.periodic(Duration(milliseconds: 1200), (timer) {
      if (floatingMessages.length < 4 && _show3DModel) {
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
      startX: random.nextDouble() * 0.6 + 0.2, // 20% à 80% de la largeur
      animationController: animationController,
      onComplete: () {
        setState(() {
          floatingMessages.removeWhere(
            (msg) =>
                msg.text == message &&
                msg.animationController == animationController,
          );
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
    emailController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    _formController.dispose();
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
              Color(0xFF4FC3F7), // Bleu clair
              Color(0xFF26C6DA), // Cyan
              Color(0xFF00BCD4), // Turquoise
              Color(0xFF009688), // Vert turquoise
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Layout principal
              SingleChildScrollView(
                child: Container(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    children: [
                      // Instruction en haut
                      AnimatedOpacity(
                        opacity: _show3DModel ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 600),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Veuillez vous identifier ici',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Zone du modèle 3D avec key pour positioning
                      Expanded(
                        flex: 2,
                        child: Container(
                          key: _modelKey,
                          child: Center(
                            child:
                                _show3DModel
                                    ? AnimatedBuilder(
                                      animation: _bounceAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _bounceAnimation.value,
                                          child: FadeTransition(
                                            opacity: _fadeAnimation,
                                            child: Container(
                                              width: 200,
                                              height: 200,
                                              child: O3D(
                                                src: 'assets/danse1.glb',
                                                controller: controller,
                                                ar: false,
                                                autoPlay: true,
                                                autoRotate: true,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      width: 200,
                                      height: 200,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                                  ),
                                              strokeWidth: 2,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Chargement...',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      ),

                      // Formulaire de connexion
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _showForm
                                  ? AnimatedBuilder(
                                    animation: _formController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          _formSlideAnimation.value,
                                        ),
                                        child: Transform.scale(
                                          scale: _formScaleAnimation.value,
                                          child: FadeTransition(
                                            opacity: _formFadeAnimation,
                                            child: Container(
                                              padding: EdgeInsets.all(28),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 25,
                                                    offset: Offset(0, 15),
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // Titre
                                                    Text(
                                                      'Connexion',
                                                      style: TextStyle(
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF2C3E50,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),

                                                    SizedBox(height: 25),

                                                    // Champ Email
                                                    TextFormField(
                                                      controller:
                                                          emailController,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            'Adresse email',
                                                        hintText:
                                                            'exemple@email.com',
                                                        prefixIcon: Icon(
                                                          Icons.email_outlined,
                                                          color: Color(
                                                            0xFF009688,
                                                          ),
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color: Color(
                                                                      0xFF009688,
                                                                    ),
                                                                    width: 2,
                                                                  ),
                                                            ),
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey.shade50,
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Veuillez entrer votre email';
                                                        }
                                                        if (!RegExp(
                                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                        ).hasMatch(value)) {
                                                          return 'Veuillez entrer un email valide';
                                                        }
                                                        return null;
                                                      },
                                                    ),

                                                    SizedBox(height: 25),

                                                    // Bouton de connexion
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          print(
                                                            'Email: ${emailController.text}',
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color(
                                                          0xFF009688,
                                                        ),
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 16,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        elevation: 3,
                                                      ),
                                                      child: Text(
                                                        'Se connecter',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 18),

                                                    // Séparateur
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Divider(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            thickness: 1,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                              ),
                                                          child: Text(
                                                            'ou',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Divider(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            thickness: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 18),

                                                    // Bouton Google
                                                    OutlinedButton.icon(
                                                      onPressed: () async {
                                                        try {
                                                          final userCredential =
                                                              await AuthService()
                                                                  .signInWithGoogle();
                                                          if (userCredential !=
                                                              null) {
                                                            // Redirection après connexion réussie
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Accueil(),
                                                              ),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          print(
                                                            "Erreur lors de la connexion Google: $e",
                                                          );
                                                        }
                                                      },
                                                      icon: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child: Image.network(
                                                          'https://developers.google.com/identity/images/g-logo.png',
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Icon(
                                                              Icons
                                                                  .g_mobiledata,
                                                              color: Colors.red,
                                                              size: 20,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      label: Text(
                                                        'Continuer avec Google',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                            0xFF2C3E50,
                                                          ),
                                                        ),
                                                      ),
                                                      style: OutlinedButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 16,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          width: 1.5,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Messages flottants par-dessus tout
              ...floatingMessages
                  .map(
                    (message) => FloatingMessageWidget(
                      message: message,
                      modelKey: _modelKey,
                    ),
                  )
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
  final GlobalKey modelKey;

  const FloatingMessageWidget({
    Key? key,
    required this.message,
    required this.modelKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: message.animationController,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Obtenir la position de la zone du modèle 3D
        final RenderBox? renderBox =
            modelKey.currentContext?.findRenderObject() as RenderBox?;
        final modelPosition =
            renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        final modelSize = renderBox?.size ?? Size.zero;

        // Position Y: du bas de la zone du modèle vers le haut
        final modelBottom = modelPosition.dy + modelSize.height;
        final modelHeight = modelSize.height;

        final yPosition =
            modelBottom -
            (modelHeight * message.animationController.value * 1.2);

        // Position X: dans la zone du modèle
        final modelLeft = modelPosition.dx;
        final modelWidth = modelSize.width;
        final xPosition = modelLeft + (modelWidth * message.startX);

        // Opacité: 0 -> 1 -> 0
        double opacity;
        if (message.animationController.value < 0.2) {
          opacity = message.animationController.value / 0.2;
        } else if (message.animationController.value < 0.8) {
          opacity = 1.0;
        } else {
          opacity = (1.0 - message.animationController.value) / 0.2;
        }

        // Vérifier si l'animation est terminée
        if (message.animationController.value == 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            message.onComplete();
          });
        }

        return Positioned(
          left: xPosition - 30, // Centrer le message
          top: yPosition,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 11,
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
