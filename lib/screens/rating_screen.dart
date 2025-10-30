import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:rive/rive.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingSCreenState();
}

class _RatingSCreenState extends State<RatingScreen> {
  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMINumber? numLook;

  double rating = 0.0;
  int starCount = 5;

  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(artboard, "Login Machine");
    if (controller == null) return;

    artboard.addController(controller!);
    isChecking = controller!.findSMI('isChecking');
    isHandsUp = controller!.findSMI('isHandsUp');
    trigSuccess = controller!.findSMI('trigSuccess');
    trigFail = controller!.findSMI('trigFail');
    numLook = controller!.findSMI('numLook');
  }

  void _onRatingUpdate(double newRating) {
    setState(() {
      rating = newRating;
    });

    isChecking?.value = false;
    isHandsUp?.value = false;
    numLook?.value = 0.0;

    switch (newRating.toInt()) {
      case 1:
      case 2:
        trigFail?.fire();
        break;
      case 3:
        numLook?.value = 50.0;
        break;
      case 4:
      case 5:
        trigSuccess?.fire();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),

              _buildRiveAnimation(context),
              const SizedBox(height: 20),

              _buildRatingStars(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          "Enjoying Sounter?",
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap a star to rate!",
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.grey,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildRiveAnimation(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: 200,
      child: RiveAnimation.asset(
        'assets/animated_login_character.riv',
        stateMachines: const ["Login Machine"],
        onInit: _onRiveInit,
      ),
    );
  }

  Widget _buildRatingStars() {
    return Center(
      child: StarRating(
        size: 40.0,
        rating: rating,
        color: Colors.orange,
        borderColor: Colors.grey,
        allowHalfRating: false,
        starCount: starCount,
        onRatingChanged: _onRatingUpdate,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
