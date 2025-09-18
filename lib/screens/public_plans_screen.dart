import 'package:flutter/material.dart';
import '../services/public_service.dart';

class PublicPlansScreen extends StatelessWidget {
  const PublicPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Plans')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PublicService().getTopPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return const Center(child: Text('No public plans found.'));
          }
          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, i) {
              final plan = plans[i];
              final planId = plan['id'] ?? plan['planId'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(plan['title'] ?? 'Untitled'),
                  subtitle: Text('By: ${plan['creatorName'] ?? 'Anonymous'} | Topic: ${plan['topic'] ?? ''}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text('${plan['avgRating']?.toStringAsFixed(1) ?? '0.0'}'),
                        ],
                      ),
                      Text('${plan['raterCount'] ?? 0} ratings'),
                    ],
                  ),
                  onTap: () async {
                    if (planId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan id not available for ratings.')));
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    final stars = await showDialog<int>(
                      context: context,
                      builder: (ctx) {
                        int current = 5;
                        return AlertDialog(
                          title: const Text('Rate this plan'),
                          content: StatefulBuilder(builder: (c, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (j) {
                                return IconButton(
                                  icon: Icon(j < current ? Icons.star : Icons.star_border, color: Colors.amber),
                                  onPressed: () => setState(() => current = j + 1),
                                );
                              }),
                            );
                          }),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(current), child: const Text('Submit')),
                          ],
                        );
                      },
                    );
                    if (stars != null) {
                      await PublicService().ratePlan(planId, stars);
                      messenger.showSnackBar(const SnackBar(content: Text('Thanks for rating')));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
