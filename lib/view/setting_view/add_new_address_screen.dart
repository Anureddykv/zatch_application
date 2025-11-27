import 'package:flutter/material.dart';import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Address {
  String id;
  String title;
  String fullAddress;
  String phone;
  IconData icon;

  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.phone,
    required this.icon,
  });
}

class AddNewAddressScreen extends StatefulWidget {
  final Address? addressToEdit;

  const AddNewAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController labelController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedAddressType;
  String? selectedState;
  bool _isLocating = false;

  final List<String> addressTypes = ["Home", "Office", "Others"];
  final List<String> indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
    "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana",
    "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal",
    "Andaman and Nicobar Islands", "Chandigarh", "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi", "Jammu and Kashmir", "Ladakh", "Lakshadweep", "Puducherry"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      final address = widget.addressToEdit!;

      // Set the address type dropdown and label controller
      if (addressTypes.contains(address.title)) {
        selectedAddressType = address.title;
        labelController.text = address.title; // Pre-fill for validation
      } else {
        selectedAddressType = "Others";
        labelController.text = address.title; // This is the custom label
      }

      phoneController.text = address.phone.replaceAll('+91 ', '').trim();

      final addressParts = address.fullAddress.split(',').map((s) => s.trim()).toList();
      if (addressParts.length >= 3) {
        address1Controller.text = addressParts.isNotEmpty ? addressParts[0] : '';
        address2Controller.text = addressParts.length > 1 ? addressParts[1] : '';
        cityController.text = addressParts.length > 2 ? addressParts[2] : '';
        if (addressParts.length > 3) {
          pinCodeController.text = addressParts[3].replaceAll(RegExp(r'[^0-9]'), '');
        }
        if (addressParts.length > 4) {
          final statePart = addressParts[4];
          if (indianStates.contains(statePart)) {
            selectedState = statePart;
          }
        }
      } else {
        address1Controller.text = address.fullAddress;
      }
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLocateMe() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Location services are disabled.');
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied.');
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied.');
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        setState(() {
          address1Controller.text = '${placemark.street}, ${placemark.thoroughfare}';
          address2Controller.text = placemark.subLocality ?? '';
          cityController.text = placemark.locality ?? '';
          pinCodeController.text = placemark.postalCode ?? '';
          if (placemark.administrativeArea != null && indianStates.contains(placemark.administrativeArea)) {
            selectedState = placemark.administrativeArea;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get location: ${e.toString()}');
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  void _saveOrUpdateAddress() {
    if (_formKey.currentState!.validate()) {
      // The labelController is now the single source of truth for the title.
      // It's either set by the dropdown or the custom text field.
      final fullAddress = [
        address1Controller.text.trim(),
        address2Controller.text.trim(),
        cityController.text.trim(),
        pinCodeController.text.trim(),
        selectedState ?? ''
      ].where((s) => s.isNotEmpty).join(', ');

      final newAddress = Address(
        id: widget.addressToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: labelController.text.trim(),
        fullAddress: fullAddress,
        phone: '+91 ${phoneController.text.trim()}',
        icon: _getIconForLabel(labelController.text.trim()),
      );

      Navigator.pop(context, newAddress);
    } else {
      _showErrorSnackBar('Please fix the errors in the form.');
    }
  }

  IconData _getIconForLabel(String label) {
    String lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('home')) return Icons.home_outlined;
    if (lowerLabel.contains('office') || lowerLabel.contains('work')) return Icons.apartment_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Address" : "Add New Address", style: const TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  "https://i.stack.imgur.com/g2242.png", // Generic map image
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.map, color: Colors.grey, size: 50),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: ElevatedButton.icon(
                    onPressed: _isLocating ? null : _handleLocateMe,
                    icon: _isLocating ? Container(width: 20, height: 20, margin: const EdgeInsets.only(right: 8), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black,)) : const Icon(Icons.my_location),
                    label: Text(_isLocating ? 'Locating...' : 'Locate Me'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCF656),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? 'Update Address Details' : 'Or, Add Address Details Manually', style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'DM Sans', fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),

                    _CustomDropdown(
                      value: selectedAddressType,
                      labelText: 'Address Type',
                      hint: 'Select Address Type',
                      items: addressTypes,
                      onChanged: (value) {
                        setState(() {
                          selectedAddressType = value;
                          if (value != "Others") {
                            labelController.text = value ?? '';
                          } else {
                            labelController.clear();
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Please select a type' : null,
                    ),
                    const SizedBox(height: 16),

                    if (selectedAddressType == "Others")
                      Column(
                        children: [
                          _CustomTextField(
                            controller: labelController,
                            labelText: 'Custom Label',
                            hintText: 'Enter a custom label',
                            maxLength: 20,
                            validator: (value) {
                              if (selectedAddressType == "Others" && (value == null || value.isEmpty)) {
                                return 'Please enter a custom label';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    _CustomTextField(
                      controller: address1Controller,
                      labelText: 'Address line - 1',
                      hintText: 'Enter Flat No, Building Name, Street',
                      maxLength: 150,
                      validator: (value) => value == null || value.isEmpty ? 'Address line 1 is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: address2Controller,
                      labelText: 'Address line - 2 (Optional)',
                      hintText: 'Enter Area, Landmark',
                      maxLength: 150,
                    ),
                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: cityController,
                      labelText: 'City',
                      hintText: 'Enter City',
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a city' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _CustomDropdown(
                            value: selectedState,
                            labelText: 'State',
                            hint: 'Select State',
                            items: indianStates,
                            onChanged: (value) => setState(() => selectedState = value),
                            validator: (value) => value == null ? 'Please select a state' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _CustomTextField(
                            controller: pinCodeController,
                            labelText: 'Pin Code',
                            hintText: '6 digits',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (value.length != 6) return '6 digits only';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _CustomTextField(
                      controller: phoneController,
                      labelText: 'Phone',
                      hintText: '10-digit number',
                      keyboardType: TextInputType.phone,
                      prefixText: '+91',
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Phone number is required';
                        if (value.length != 10) return 'Must be 10 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _saveOrUpdateAddress,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFFCCF656),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(isEditing ? "Update Address" : "Save Address", style: const TextStyle(fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.prefixText,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans'),
            prefixIcon: prefixText != null
                ? Padding(
              padding: const EdgeInsets.only(left: 24, right: 8, top: 13, bottom: 13),
              child: Text(prefixText!, style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Plus Jakarta Sans')),
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final String labelText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _CustomDropdown({
    required this.value,
    required this.hint,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans')),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            isDense: true,
          ),
          items: items.map((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(state, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ],
    );
  }
}
