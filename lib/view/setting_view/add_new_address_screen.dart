import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zatch_app/model/address_model.dart';
import 'package:zatch_app/services/api_service.dart';

class AddNewAddressScreen extends StatefulWidget {
  final Address? addressToEdit;

  const AddNewAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // --- Map Controller & State ---
  final Completer<GoogleMapController> _mapController = Completer();
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867), // Default to Hyderabad
    zoom: 11.0,
  );
  Set<Marker> _markers = {};

  // --- Form Controllers ---
  final TextEditingController labelController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // --- UI State ---
  String? selectedAddressType;
  String? selectedState;
  bool _isLocating = false;
  bool _isSaving = false;
  Position? _currentPosition;

  final List<String> addressTypes = ["Home", "Office", "Others"];
  final List<String> indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", "Haryana",
    "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
    "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
    "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh", "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi", "Jammu and Kashmir", "Ladakh", "Lakshadweep", "Puducherry"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      // If editing, populate the form with existing data
      _populateFormForEdit();
    }

  }

  void _populateFormForEdit() {
    final address = widget.addressToEdit!;
    labelController.text = address.label;
    address1Controller.text = address.line1;
    address2Controller.text = address.line2 ?? '';
    cityController.text = address.city;
    pinCodeController.text = address.pincode;
    phoneController.text = address.phone.replaceAll('+91', '').trim();
    if (addressTypes.contains(address.type)) {
      selectedAddressType = address.type;
    } else {
      selectedAddressType = "Others";
    }
    if (indianStates.contains(address.state)) {
      selectedState = address.state;
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
        throw Exception('Location services are disabled. Please turn on GPS.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Settings > App > Permissions.');
      }

      print("📍 Geolocator: Fetching current position (Timeout: 20s)...");
   final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      _currentPosition = position;

      print("🚀 GENERATING REQUEST:");
      print("   LAT: ${position.latitude}");
      print("   LNG: ${position.longitude}");

      // 4. Update Map
      if (mounted) {
        await _animateCameraAndAddMarker(LatLng(position.latitude, position.longitude));
      }

      print("📞 API Call: Sending request to /address/geocode...");

      try {
        final addressData = await _apiService.geocodeAddress(position.latitude, position.longitude);
        print("✅ API Response Received: $addressData");

        if (mounted) {
          setState(() {
            address1Controller.text = addressData['line1'] ?? '';
            address2Controller.text = addressData['line2'] ?? '';
            cityController.text = addressData['city'] ?? '';
            pinCodeController.text = addressData['pincode'] ?? '';

            String? incomingState = addressData['state'];
            if (incomingState != null) {
              if (indianStates.contains(incomingState)) {
                selectedState = incomingState;
              }
              else {
                try {
                  selectedState = indianStates.firstWhere(
                          (s) => s.toLowerCase() == incomingState.toLowerCase()
                  );
                } catch (e) {
                  print("State mismatch: $incomingState not found in list");
                }
              }
            }
          });
        }
      } catch (apiError) {
        print("⚠️ API Error during geocoding: $apiError");
        _showErrorSnackBar('Found location, but could not fetch address text.');
      }

    } on TimeoutException catch (_) {
      print("❌ Geolocator Timeout");
      _showErrorSnackBar("GPS timed out. Please try again or move to an open area.");
    } catch (e) {
      print("❌ Error in _handleLocateMe: $e");
      _showErrorSnackBar(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

      Future<void> _animateCameraAndAddMarker(LatLng position) async {
      final GoogleMapController controller = await _mapController.future;

      if (!mounted) return; // Check if screen is valid

      try {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 16.0),
      ));
      } catch (e) {
      debugPrint("Error animating camera: $e");
      }

      if (!mounted) return; // Check again before updating UI

      setState(() {
      _markers = {
      Marker(
      markerId: const MarkerId('currentLocation'),
      position: position,
      infoWindow: const InfoWindow(title: 'Your Location'),
        )
      };
    });
  }

  void _saveOrUpdateAddress() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix the errors in the form.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = {
        "addressId": widget.addressToEdit?.id,
        "label": labelController.text.trim(),
        "type": selectedAddressType!,
        "line1": address1Controller.text.trim(),
        "line2": address2Controller.text.trim(),
        "city": cityController.text.trim(),
        "state": selectedState!,
        "pincode": pinCodeController.text.trim(),
        "phone": phoneController.text.trim(),
        "lat": _currentPosition?.latitude,
        "lng": _currentPosition?.longitude,
      };
      print("📞 API Call (Save Address): $payload");

      final savedAddress = await _apiService.saveAddress(
        addressId: payload['addressId'] as String?,
        label: payload['label'] as String,
        type: payload['type'] as String,
        line1: payload['line1'] as String,
        line2: payload['line2'] as String?,
        city: payload['city'] as String,
        state: payload['state'] as String,
        pincode: payload['pincode'] as String,
        phone: payload['phone'] as String,
        lat: payload['lat'] as double?,
        lng: payload['lng'] as double?,
      );
      print("✅ API Response (Save Address): ${savedAddress.toJson()}");

      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      _showErrorSnackBar('Failed to save address: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
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
            // --- MAP WIDGET ---
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    // ✅ CHANGE 2: Enable the 'current location' button behavior internally (optional)
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    // ✅ CHANGE 3: Add gestures for better UX
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                  ),
                  Positioned(
                    bottom: 20,
                    child: ElevatedButton.icon(
                      onPressed: _isLocating ? null : _handleLocateMe,
                      icon: _isLocating
                          ? Container(
                          width: 20, height: 20,
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.my_location),
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
            ),
            // --- FORM FIELDS ---
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
                          labelController.text = (value != "Others") ? (value ?? '') : '';
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
                      onPressed: _isSaving ? null : _saveOrUpdateAddress,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFFCCF656),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(isEditing ? "Update Address" : "Save Address", style: const TextStyle(fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)),
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

// Keep your _CustomTextField and _CustomDropdown widgets unchanged.
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
