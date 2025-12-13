// lib/pages/log_activity_page.dart

import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class LogActivityPage extends StatefulWidget {
  const LogActivityPage({super.key});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String? _selectedType;
  String? _selectedUnit;
  bool _isLoading = false;

  final Map<String, String> _materialUnits = {
    'Plastic Bottles': 'bottles',
    'Paper (kg)': 'kg',
    'Aluminium Cans': 'cans',
  };

  Future<void> _submitActivity() async {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      setState(() {
        _isLoading = true;
      });

      final type = _selectedType!;
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final unit = _selectedUnit!;
      
      try {
        await ActivityService().recordActivity(type, quantity, unit);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Activity logged successfully! Check your dashboard for new points.'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
          // Pop to return to the Dashboard
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log activity: ${e.toString()}')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Recycling Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Record Your Contribution',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 24),
              
              // --- Material Type Dropdown ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Material Type',
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedType,
                items: _materialUnits.keys.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                    _selectedUnit = newValue != null ? _materialUnits[newValue] : null;
                  });
                },
                validator: (value) => value == null ? 'Please select a material type' : null,
              ),
              const SizedBox(height: 16),
              
              // --- Quantity Input ---
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  suffixText: _selectedUnit ?? 'units',
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // --- Submit Button ---
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitActivity,
                icon: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isLoading ? 'Processing...' : 'Submit Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}