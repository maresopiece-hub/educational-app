import 'package:flutter/material.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lesson Plan')),
      body: const Center(child: Text('Build or edit your lesson plan here.')),
    );
  }
}
