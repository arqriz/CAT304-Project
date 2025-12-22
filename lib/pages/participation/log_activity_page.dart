import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class LogActivityPage extends StatefulWidget {
  const LogActivityPage({super.key});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final ActivityService _activityService = ActivityService();
  
  String _selectedType = 'Plastic';
  final TextEditingController _quantityController = TextEditingController();
  bool _isSubmitting = false;

  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  // Added new items for testing and stimulation
  final List<String> _categories = [
    'Plastic', 
    'Paper', 
    'Glass', 
    'Metal', 
    'Organic',
    'E-waste',
    'Textiles'
  ];

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final double quantity = double.parse(_quantityController.text);
      
      // Use recordActivity to log data and update user points
      await _activityService.recordActivity(
        _selectedType, 
        quantity, 
        'kg',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSage,
      appBar: AppBar(
        title: const Text('Log Activity'),
        backgroundColor: mossGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What did you recycle?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mossGreen),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: creamWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: mossGreen)),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedType = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Quantity (kg)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mossGreen),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter weight in kg",
                  fillColor: creamWhite,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a number';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mossGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Log Activity"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}