import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class MotivationalPopup extends StatelessWidget {
  final String message;
  final String animationAsset;
  final VoidCallback? onClose;

  const MotivationalPopup({
    super.key,
    required this.message,
    required this.animationAsset,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: FlareActor(
              animationAsset,
              animation: 'play',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 2))],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
