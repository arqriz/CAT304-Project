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

  // 1. DATA MAP: Link categories to image paths
  final List<Map<String, String>> _categoryData = [
    {'name': 'Plastic', 'image': 'assets/images/plastic.png'},
    {'name': 'Paper', 'image': 'assets/images/paper.png'},
    {'name': 'Glass', 'image': 'assets/images/glass.png'},
    {'name': 'Metal', 'image': 'assets/images/metal.png'},
    {'name': 'Organic', 'image': 'assets/images/organic.png'},
    {'name': 'E-waste', 'image': 'assets/images/ewaste.png'},
    {'name': 'Textiles', 'image': 'assets/images/textiles.png'},
  ];

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final double quantity = double.parse(_quantityController.text);

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
    // Find current image for the preview
    final currentImage =
        _categoryData.firstWhere((e) => e['name'] == _selectedType)['image']!;

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
              // 2. VISUAL PREVIEW: Shows the image of the selected category
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: creamWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: mossGreen.withOpacity(0.1), blurRadius: 10)
                      ]),
                  child: Image.asset(
                    currentImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.recycling, size: 50, color: mossGreen),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "What did you recycle?",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: mossGreen),
              ),
              const SizedBox(height: 20),

              // 3. UPDATED DROPDOWN: Including Images
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                decoration: BoxDecoration(
                  color: creamWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_circle,
                        color: mossGreen),
                    items: _categoryData.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Row(
                          children: [
                            Image.asset(
                              category['image']!,
                              width: 30,
                              height: 30,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.category, size: 24),
                            ),
                            const SizedBox(width: 15),
                            Text(category['name']!,
                                style: const TextStyle(
                                    color: mossGreen,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedType = newValue!),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                "Quantity (kg)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mossGreen),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: mossGreen),
                decoration: InputDecoration(
                  hintText: "Enter weight in kg",
                  prefixIcon: const Icon(Icons.scale, color: mossGreen),
                  fillColor: creamWhite,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a number';
                  if (double.tryParse(value) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: mossGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "LOG ACTIVITY",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
      ),
    );
  }
}
