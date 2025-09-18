import 'package:flutter_test/flutter_test.dart';
import 'package:confetti/confetti.dart';

void main() {
  test('confetti controller plays on milestone', () {
    final controller = ConfettiController(duration: const Duration(seconds: 1));
    expect(controller.state, ConfettiControllerState.stopped);
    controller.play();
    // After calling play the state should be playing (timed)
    expect(controller.state, ConfettiControllerState.playing);
    controller.dispose();
  });
}
