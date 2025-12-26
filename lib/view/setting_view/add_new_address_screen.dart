import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zatch/model/address_model.dart';
import 'package:zatch/services/api_service.dart';

class AddNewAddressScreen extends StatefulWidget {
  final Address? addressToEdit;

  const AddNewAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final Completer<GoogleMapController> _mapController = Completer();

  late CameraPosition _initialCameraPosition;
  Set<Marker> _markers = {};

  final TextEditingController labelController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
    _initializeMapLocation();
  }

  void _initializeMapLocation() {
    // Default to Hyderabad if nothing else works
    LatLng targetPos = const LatLng(17.3850, 78.4867);

    // 1. If Editing, check if saved coordinates exist in the model
    if (widget.addressToEdit != null &&
        widget.addressToEdit!.lat != null &&
        widget.addressToEdit!.lng != null) {

      targetPos = LatLng(widget.addressToEdit!.lat!, widget.addressToEdit!.lng!);

      _markers = {
        Marker(
          markerId: const MarkerId('savedLocation'),
          position: targetPos,
        )
      };

      // Crucial: Initialize _currentPosition so saving works without moving map
      _currentPosition = Position(
        latitude: targetPos.latitude,
        longitude: targetPos.longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0, altitude: 0.0, heading: 0.0, speed: 0.0,
        speedAccuracy: 0.0, altitudeAccuracy: 1.0, headingAccuracy: 1.0,
      );

      _populateFormForEdit();
    }
    // 2. If New Address, start location tracking
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLocateMe();
      });
    }

    _initialCameraPosition = CameraPosition(
      target: targetPos,
      zoom: 15.0,
    );
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
      // 1. Check Service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optional: Open location settings
        // await Geolocator.openLocationSettings();
        throw Exception('Location services are disabled. Please turn on GPS.');
      }

      // 2. Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      print("📍 Geolocator: Attempting to get location...");

      // 3. RETRIEVE LOCATION
      // First try last known (instant)
      Position? position = await Geolocator.getLastKnownPosition();

      // If null, get current (takes a few seconds)
      if (position == null) {
        print("📍 Fetching fresh location...");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      }

      // Update state
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      print("🚀 LOCATION FOUND: ${position.latitude}, ${position.longitude}");

      // 4. Update Map Camera
      if (mounted) {
        await _animateCameraAndAddMarker(
            LatLng(position.latitude, position.longitude));
      }

      // 5. Geocoding API Call (Only if not editing or explicitly requested)
      // If we are just starting up and editing, we might not want to overwrite data immediately
      // But since _handleLocateMe is called automatically only for NEW addresses, this is safe.
      try {
        final addressData = await _apiService.geocodeAddress(
            position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            address1Controller.text = addressData['line1'] ?? '';
            address2Controller.text = addressData['line2'] ?? '';
            cityController.text = addressData['city'] ?? '';
            pinCodeController.text = addressData['pincode'] ?? '';

            String? incomingState = addressData['state'];
            if (incomingState != null) {
              try {
                selectedState = indianStates.firstWhere(
                      (s) => s.toLowerCase() == incomingState.toLowerCase(),
                  orElse: () => incomingState,
                );
                if (!indianStates.contains(selectedState)) {
                  selectedState = null;
                }
              } catch (e) {
                print("State match error: $e");
              }
            }
          });
        }
      } catch (apiError) {
        print("⚠️ API Error during geocoding: $apiError");
      }
    } catch (e) {
      print("❌ Error in _handleLocateMe: $e");
      // Don't show snackbar on auto-load to avoid annoyance,
      // only show if user manually clicked button or major error.
      if(_isLocating) {
        // logic to differentiate auto-load vs manual click could be added
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _animateCameraAndAddMarker(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;

    if (!mounted) return;

    try {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16.0),
      ));
    } catch (e) {
      debugPrint("Error animating camera: $e");
    }

    if (!mounted) return;

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
    }    setState(() => _isSaving = true);

    // Get current lat/lng from the map/geolocator state
    double? finalLat = _currentPosition?.latitude;
    double? finalLng = _currentPosition?.longitude;

    // Fallback if user didn't click "Locate Me" but coordinates are in the edit model
    if (finalLat == null && widget.addressToEdit != null) {
      finalLat = widget.addressToEdit!.lat;
      finalLng = widget.addressToEdit!.lng;
    }

    try {
      // Build request payload exactly as you requested
      // { label, type, line1, line2, city, state, pincode, phone, lat, lng, isDefault }
      await _apiService.saveAddress(
        addressId: widget.addressToEdit?.id, // ID only used for URL, not payload
        label: labelController.text.trim(),
        type: selectedAddressType ?? "Home",
        line1: address1Controller.text.trim(),
        line2: address2Controller.text.trim(),
        city: cityController.text.trim(),
        state: selectedState ?? "",
        pincode: pinCodeController.text.trim(),
        phone: phoneController.text.trim(),
        lat: finalLat,
        lng: finalLng,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Failed to save address: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Address" : "Add New Address",
            style: const TextStyle(
                color: Color(0xFF121111),
                fontSize: 16,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600)),
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
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                  ),
                  Positioned(
                    bottom: 20,
                    child: ElevatedButton.icon(
                      onPressed: _isLocating ? null : _handleLocateMe,
                      icon: _isLocating
                          ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.my_location),
                      label: Text(_isLocating ? 'Locating...' : 'Locate Me'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCF656),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
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
                    Text(
                        isEditing
                            ? 'Update Address Details'
                            : 'Or, Add Address Details Manually',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),

                    _CustomDropdown(
                      value: selectedAddressType,
                      labelText: 'Address Type',
                      hint: 'Select Address Type',
                      items: addressTypes,
                      onChanged: (value) {
                        setState(() {
                          selectedAddressType = value;
                          labelController.text =
                          (value != "Others") ? (value ?? '') : '';
                        });
                      },
                      validator: (value) =>
                      value == null ? 'Please select a type' : null,
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
                              if (selectedAddressType == "Others" &&
                                  (value == null || value.isEmpty)) {
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Address line 1 is required'
                          : null,
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a city'
                          : null,
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
                            onChanged: (value) =>
                                setState(() => selectedState = value),
                            validator: (value) => value == null
                                ? 'Please select a state'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _CustomTextField(
                            controller: pinCodeController,
                            labelText: 'Pin Code',
                            hintText: '6 digits',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
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
                        if (value == null || value.isEmpty)
                          return 'Phone number is required';
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(isEditing ? "Update Address" : "Save Address",
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Encode Sans',
                              fontWeight: FontWeight.w700)),
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
        Text(labelText,
            style: const TextStyle(
                color: Color(0xFFABABAB),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w500)),
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
            hintStyle: const TextStyle(
                color: Color(0xFF616161),
                fontSize: 16,
                fontFamily: 'Encode Sans'),
            prefixIcon: prefixText != null
                ? Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 8, top: 13, bottom: 13),
              child: Text(prefixText!,
                  style: const TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans')),
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
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
        Text(labelText,
            style: const TextStyle(
                color: Color(0xFFABABAB),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          hint: Text(hint,
              style: const TextStyle(
                  color: Color(0xFF616161),
                  fontSize: 16,
                  fontFamily: 'Encode Sans')),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
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
