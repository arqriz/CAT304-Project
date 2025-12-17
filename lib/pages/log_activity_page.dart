import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class LogActivityPage extends StatefulWidget {
  const LogActivityPage({super.key});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  final _quantityController = TextEditingController();
  String _selectedType = 'Plastic';
  String _selectedUnit = 'kg';
  bool _isLoading = false;

  Future<void> _submitActivity() async {
    setState(() => _isLoading = true);
    try {
      double qty = double.tryParse(_quantityController.text) ?? 0.0;
      
      // Call the service method we just created
      await ActivityService().recordActivity(_selectedType, qty, _selectedUnit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity Logged Successfully!')),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Recycling')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _submitActivity, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}