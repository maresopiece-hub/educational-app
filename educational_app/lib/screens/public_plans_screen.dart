import 'package:flutter/material.dart';
import '../services/public_service.dart';

class PublicPlansScreen extends StatefulWidget {
  const PublicPlansScreen({super.key});

  @override
  State<PublicPlansScreen> createState() => _PublicPlansScreenState();
}

class _PublicPlansScreenState extends State<PublicPlansScreen> {
  Future<void> _downloadPlan(Map<String, dynamic> plan) async {
    // Save plan to local DB (replace with actual logic)
    // await DatabaseService.instance.insertPlan(plan);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan "${plan['title'] ?? 'Untitled'}" downloaded!')),
    );
  }
  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await PublicService().fetchPublicPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load plans: $e';
        _loading = false;
      });
    }
  }

  Future<void> _ratePlan(String planId, int rating) async {
    try {
      await PublicService().ratePlan(planId, rating);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for rating!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to rate: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Public Plans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _plans.length,
                  itemBuilder: (context, idx) {
                    final plan = _plans[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(plan['title'] ?? 'Untitled'),
                        subtitle: Text('By: ${plan['author'] ?? 'Unknown'}\nRating: ${plan['rating'] ?? 0}/5'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadPlan(plan),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(plan['title'] ?? 'Untitled'),
                              content: Text(plan['description'] ?? 'No description.'),
                              actions: [
                                for (int i = 1; i <= 5; i++)
                                  IconButton(
                                    icon: Icon(Icons.star, color: (plan['rating'] ?? 0) >= i ? Colors.amber : Colors.grey),
                                    onPressed: () => _ratePlan(plan['id'], i),
                                  ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
