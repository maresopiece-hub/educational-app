import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;
  const LoadingOverlay({required this.loading, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
        if (loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
