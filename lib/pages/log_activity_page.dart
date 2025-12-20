import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class LogActivityPage extends StatefulWidget {
  const LogActivityPage({super.key});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Plastic';
  final TextEditingController _quantityController = TextEditingController();
  bool _isSubmitting = false;

  // FIXED: Changed to static const 
  static const Color mossGreen = Color(0xFF5B6739);
  static const Color lightSage = Color(0xFFDDE2C9);
  static const Color creamWhite = Color(0xFFF9F9F0);

  final List<String> _categories = ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic'];

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final double quantity = double.parse(_quantityController.text);
      final int points = (quantity * 10).toInt();

      await FirebaseFirestore.instance.collection('activities').add({
        'userId': user.uid,
        'type': _selectedType,
        'quantity': quantity,
        'unit': 'kg',
        'pointsEarned': points,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(points),
        'totalRecycled': FieldValue.increment(quantity),
        'co2Saved': FieldValue.increment(quantity * 0.5),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              // FIXED: Removed 'const' before TextStyle because mossGreen is a variable
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
                        // FIXED: Removed 'const' here
                        child: Text(value, style: const TextStyle(color: mossGreen)),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedType = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // FIXED: Removed 'const' here
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
                      ? const CircularProgressIndicator(color: Colors.white)
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