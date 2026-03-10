// Form screen for creating a new listing OR editing an existing one.
// If 'place' argument is passed → Edit mode.
// If no 'place' argument → Add mode.
// Calls PlacesProvider.addPlace() or PlacesProvider.updatePlace().

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../models/place_model.dart';

class AddEditListingScreen extends StatefulWidget {
  final PlaceModel? place; // null = Add mode, non-null = Edit mode

  const AddEditListingScreen({super.key, this.place});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  String _selectedCategory = 'Hospital';

  bool get _isEditMode => widget.place != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    final p = widget.place;
    _nameController = TextEditingController(text: p?.name ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _contactController = TextEditingController(text: p?.contactNumber ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _latController = TextEditingController(
      text: p?.latitude.toString() ?? '-1.9441',
    );
    _lngController = TextEditingController(
      text: p?.longitude.toString() ?? '30.0619',
    );
    _selectedCategory = p?.category ?? 'Hospital';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final placesProvider = context.read<PlacesProvider>();
    final uid = authProvider.firebaseUser!.uid;

    // Build the PlaceModel from form fields
    final newPlace = PlaceModel(
      id: widget.place?.id, // Keep ID if editing
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.tryParse(_latController.text.trim()) ?? -1.9441,
      longitude: double.tryParse(_lngController.text.trim()) ?? 30.0619,
      createdBy: uid,
      timestamp: widget.place?.timestamp ?? DateTime.now(),
    );

    bool success;
    if (_isEditMode) {
      success = await placesProvider.updatePlace(newPlace);
    } else {
      success = await placesProvider.addPlace(newPlace);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Listing updated!' : 'Listing added!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(placesProvider.errorMessage ?? 'Error saving.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Listing' : 'Add New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                _nameController,
                'Place / Service Name',
                Icons.place,
                'Name is required',
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: kCategories
                    .where((c) => c != 'All')
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 12),

              _buildField(_addressController, 'Address', Icons.home, null),
              const SizedBox(height: 12),
              _buildField(
                _contactController,
                'Contact Number',
                Icons.phone,
                null,
              ),
              const SizedBox(height: 12),
              _buildField(
                _descriptionController,
                'Description',
                Icons.description,
                null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Coordinates row
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _latController,
                      'Latitude',
                      Icons.gps_fixed,
                      null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      _lngController,
                      'Longitude',
                      Icons.gps_fixed,
                      null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Default coordinates are Kigali city center (-1.9441, 30.0619)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: placesProvider.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2B4A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: placesProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? 'Update Listing' : 'Save Listing',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? requiredMsg, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: requiredMsg != null
          ? (val) => (val == null || val.isEmpty) ? requiredMsg : null
          : null,
    );
  }
}
