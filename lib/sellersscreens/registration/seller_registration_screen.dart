import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:flutter_html/flutter_html.dart';
import 'package:zatch_app/sellersscreens/Daiilogs/common_text_field.dart';
import 'package:zatch_app/sellersscreens/SellHomeScreen.dart';
import 'package:zatch_app/sellersscreens/registration/registration_success_screen.dart';
import 'package:zatch_app/sellersscreens/status/seller_status_screen.dart';
import 'package:zatch_app/services/api_service.dart';


class SellerRegistrationScreen extends StatefulWidget {
  final int initialStep;
  const SellerRegistrationScreen({super.key,this.initialStep = 0,});

  @override
  State<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  late TabController _tabController;

  // Step 1: KYC
  final _businessNameController = TextEditingController();
  final _gstController = TextEditingController();

  // Step 2: Address
  final _pickupAddress1Controller = TextEditingController();
  final _pickupAddress2Controller = TextEditingController();
  final _pickupPinCodeController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  bool _sameAsPickup = false;

  // State variables for dropdowns
  String? _selectedPickupState;
  String? _selectedBillingState;

  final _billingAddress1Controller = TextEditingController();
  final _billingAddress2Controller = TextEditingController();
  final _billingPinCodeController = TextEditingController();
  final _billingPhoneController = TextEditingController();

  // Step 3: Bank Details
  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();

  // Step 4: T&C
  bool _agreedToTerms = false;

  // Data for the state dropdown
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentStep = widget.initialStep;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentStep);
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _tabController.dispose();
    _pageController.dispose();
    _businessNameController.dispose();
    _gstController.dispose();
    _pickupAddress1Controller.dispose();
    _pickupAddress2Controller.dispose();
    _pickupPinCodeController.dispose();
    _pickupPhoneController.dispose();
    _billingAddress1Controller.dispose();
    _billingAddress2Controller.dispose();
    _billingPinCodeController.dispose();
    _billingPhoneController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_businessNameController.text.isEmpty) {
          _showError("Business name is required");
          return false;
        }
        if (_gstController.text.isEmpty) {
          _showError("GST Number is required");
          return false;
        }
        return true;

      case 1:
        if (_pickupAddress1Controller.text.isEmpty) {
          _showError("Pickup Address Line 1 is required");
          return false;
        }
        if (_pickupPinCodeController.text.length != 6) {
          _showError("Pickup Pin Code must be 6 digits");
          return false;
        }
        if (_selectedPickupState == null) {
          _showError("State is required");
          return false;
        }
        if (_pickupPhoneController.text.length != 10) {
          _showError("Phone number must be 10 digits");
          return false;
        }
        if (!_sameAsPickup) {
          if (_billingAddress1Controller.text.isEmpty) {
            _showError("Billing Address Line 1 is required");
            return false;
          }
          if (_billingPinCodeController.text.length != 6) {
            _showError("Billing Pin Code must be 6 digits");
            return false;
          }
          if (_selectedBillingState == null) {
            _showError("Billing State is required");
            return false;
          }
          if (_billingPhoneController.text.length != 10) {
            _showError("Billing Phone number must be 10 digits");
            return false;
          }
        }
        return true;

      case 2:
        if (_accountHolderNameController.text.isEmpty) {
          _showError("Account Holder Name is required");
          return false;
        }
        if (_accountNumberController.text.isEmpty) {
          _showError("Account Number is required");
          return false;
        }
        if (_ifscController.text.isEmpty) {
          _showError("IFSC Code is required");
          return false;
        }
        if (_bankNameController.text.isEmpty) {
          _showError("Bank Name is required");
          return false;
        }
        return true;

      case 3:
        if (!_agreedToTerms) {
          _showError("You must agree to the Terms & Conditions");
          return false;
        }
        return true;

      default:
        return false;
    }
  }

  Future<void> _submitStepData() async {
    if (!_validateCurrentStep()) return;

    final api = ApiService();
    Map<String, dynamic> payload = {};

    switch (_currentStep) {
      case 0:
        payload = {
          "businessName": _businessNameController.text,
          "gstNumber": _gstController.text,
        };
        break;
      case 1:
        String pickupAddress = _pickupAddress1Controller.text +
            (_pickupAddress2Controller.text.isNotEmpty ? ", ${_pickupAddress2Controller.text}" : "");

        String billingAddress;
        if (_sameAsPickup) {
          billingAddress = pickupAddress;
        } else {
          billingAddress = _billingAddress1Controller.text +
              (_billingAddress2Controller.text.isNotEmpty ? ", ${_billingAddress2Controller.text}" : "");
        }
        payload = {
          "pickupAddress": pickupAddress,
          "billingAddress": billingAddress,
          "pinCode": _pickupPinCodeController.text,
          "state": _selectedPickupState,
          "shippingMethod": _tabController.index == 0 ? "zatch_pickup" : "self_ship",
          "latitude": 19.0760,
          "longitude": 72.8777,
        };
        break;
      case 2:
        payload = {
          "accountHolderName": _accountHolderNameController.text,
          "accountNumber": _accountNumberController.text,
          "ifscCode": _ifscController.text,
          "bankName": _bankNameController.text,
          "upiId": _upiController.text,
        };
        break;
      case 3:
        payload = {
          "tcAccepted": _agreedToTerms,
        };
        break;
    }

    try {
      final response = await api.registerSellerStep(step: _currentStep + 1, payload: payload);
      _showSuccess(response["message"] ?? "Step submitted successfully");
      if (_currentStep < 3) {
        _nextPage();
      } else {
        print("✅ Registration completed.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        );
      }
    } catch (e) {
      _showError("Error submitting data: $e");
    }
  }

  String? _termsHtml;
  bool _isLoadingTerms = false;

  Future<void> _fetchTerms() async {
    setState(() => _isLoadingTerms = true);
    try {
      final api = ApiService();
      final htmlContent = await api.getSellerTermsAndConditions();
      setState(() {
        _termsHtml = htmlContent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load terms: $e")),
      );
    } finally {
      setState(() => _isLoadingTerms = false);
    }
  }


  void _nextPage() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _previousPage();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            const SizedBox(height: 30),
            _buildProgressStepper(),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1_KycInfo(),
                  _Step2_AddressInfo(),
                  _Step3_BankDetails(),
                  _Step4_TermsAndConditions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: _previousPage,
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFDFDEDE)),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          ),
        ),
      ),
      title: const Text("Register as a Seller", style: TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
      centerTitle: true,
    );
  }

  Widget _buildProgressStepper() {
    final steps = ['Shop &\nKYC Info', 'Address', 'Bank Details', 'T&C'];
    double progressPercent = _currentStep / (steps.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (index) {
              return SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 44.0,),
                  child: Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2C2C2C), fontSize: 14,
                      fontFamily: 'Inter', fontWeight: FontWeight.w400,
                      height: 1.36,
                    ),
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xFFDDDDDD)),
                FractionallySizedBox(
                  widthFactor: progressPercent,
                  child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xFFA2DC00)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(steps.length, (index) {
                    return _ProgressStepIndicator(
                      isActive: index == _currentStep,
                      isCompleted: index < _currentStep,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _Step1_KycInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStyledTextField(label: 'Business Name *', hint: 'Enter Business Name', controller: _businessNameController),
          const SizedBox(height: 20),
          _buildStyledTextField(label: 'GSTIN / Enrollment ID *', hint: 'Enter GST / Enrollment ID', controller: _gstController),
          const SizedBox(height: 12),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  const TextSpan(text: "Don't have GST Number? ", style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w400)),
                  TextSpan(
                    text: 'Apply now',
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () => print("Navigate to GST application"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2), // Spacer
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _Step2_AddressInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Shipping Method", style: TextStyle(color: Color(0xFFABABAB), fontSize: 14)),
          const SizedBox(height: 6),
          _buildShippingMethodTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShippingByZatchView(),
                _buildShippingBySelfView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingByZatchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: _buildAddressFormAndActions(),
    );
  }

  Widget _buildShippingBySelfView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: _buildAddressFormAndActions(),
    );
  }

  Widget _buildAddressFormAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick up Address', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        _buildMapPlaceholder(),
        const SizedBox(height: 20),
        _buildStyledTextField(label: "Address line - 1", hint: "Enter Address", controller: _pickupAddress1Controller),
        const SizedBox(height: 20),
        _buildStyledTextField(label: "Address line - 2", hint: "Enter Address", controller: _pickupAddress2Controller, isOptional: true),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: _buildStyledTextField(
              label: "Pin Code",
              hint: "Enter Pin Code",
              controller: _pickupPinCodeController,
              keyboardType: TextInputType.number,
              // Add input formatters for 6-digit pin
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStateDropdown(
              label: "State",
              hint: "Select State",
              value: _selectedPickupState,
              onChanged: (newValue) {
                setState(() => _selectedPickupState = newValue);
              },
            ),
          ),
        ]),
        const SizedBox(height: 20),
        _buildPhoneInput(
          controller: _pickupPhoneController,
          // Add input formatters for 10-digit phone
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 50),
        const Text('Billing Address', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(value: _sameAsPickup, onChanged: (val) => setState(() => _sameAsPickup = val!)),
            const Text('Same as Pick up address', style: TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)),
          ],
        ),
        if (!_sameAsPickup) _buildBillingAddressForm(),
        const SizedBox(height: 40),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildBillingAddressForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyledTextField(label: "Address line - 1", hint: "Enter Billing Address", controller: _billingAddress1Controller),
          const SizedBox(height: 20),
          _buildStyledTextField(label: "Address line - 2", hint: "Enter Billing Address", controller: _billingAddress2Controller, isOptional: true),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStyledTextField(
                  label: "Pin Code",
                  hint: "Enter Pin Code",
                  controller: _billingPinCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStateDropdown(
                  label: "State",
                  hint: "Select State",
                  value: _selectedBillingState,
                  onChanged: (newValue) {
                    setState(() => _selectedBillingState = newValue);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPhoneInput(
            controller: _billingPhoneController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }

  Widget _Step3_BankDetails() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildStyledTextField(
                    label: "Account Holder Name*",
                    hint: "Enter Account Holder Name",
                    controller: _accountHolderNameController),
                const SizedBox(height: 20),

                _buildStyledTextField(
                  label: "Account Number",
                  hint: "Enter Account Number",
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(18),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildStyledTextField(
                        label: "IFSC Code",
                        hint: "Enter IFSC Code",
                        controller: _ifscController,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          LengthLimitingTextInputFormatter(11),
                          FilteringTextInputFormatter.allow(RegExp(r'[aA-Z0-9]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement IFSC lookup logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCF656),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60)),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          "IFSC  Lockup",
                          style: TextStyle(
                              color: Colors.black, fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                    label: "Bank Name",
                    hint: "Enter Bank Name",
                    controller: _bankNameController),
                const SizedBox(height: 20),
                _buildStyledTextField(
                    label: "UPI ID",
                    hint: "Enter UPI ID",
                    controller: _upiController,
                    isOptional: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ]
                ),
                const SizedBox(height: 20),
                const Spacer(),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _Step4_TermsAndConditions() {
    if (_termsHtml == null && !_isLoadingTerms) {
      _fetchTerms(); // fetch only once when first entering this step
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoadingTerms
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 27.0, vertical: 16.0),
              child: _termsHtml != null
                  ? Html(
                data: _termsHtml!,
                style: {
                  "body": Style(
                    color: const Color(0xFF191919),
                    fontSize: FontSize(14),
                    lineHeight: const LineHeight(1.5),
                  ),
                },
              )
                  : const Center(
                child: Text(
                  "Failed to load Terms & Conditions.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          // Checkbox + Buttons fixed at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Checkbox Row ABOVE the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) => setState(() => _agreedToTerms = val!),
                    ),
                    const Flexible(
                      child: Text(
                        'I agree to Terms & Returns Policy',
                        style: TextStyle(
                          color: Color(0xFF191919),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildActionButtons(), // ✅ Your existing Next/Submit buttons
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: const Color(0xFFF2F4F5), borderRadius: BorderRadius.circular(60)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        indicatorPadding: const EdgeInsets.all(4),
        unselectedLabelColor: const Color(0xFF616161),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60), border: Border.all(color: Colors.white)),
        tabs: const [
          Tab(child: Text("Shipping by Zatch", style: TextStyle(fontWeight: FontWeight.w600))),
          Tab(child: Text("Shipping by self", style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    List<TextInputFormatter>? inputFormatters, // Make formatters optional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500),
              children: isOptional ? [const TextSpan(text: '(optional)', style: TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400))] : [],
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // Apply formatters here
          style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown({
    required String label,
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
          child: Text(label, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
        ),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: _indianStates.map<DropdownMenuItem<String>>((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            );
          }).toList(),
          style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildPhoneInput({
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters, // Make formatters optional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 6.0),
          child: Text("Phone", style: TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 106,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(color: const Color(0xFFF2F4F5), borderRadius: BorderRadius.circular(70)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.keyboard_arrow_down_sharp, size: 20, color: Color(0xFF616161)),
                  Text('+91', style: TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: inputFormatters, // Apply formatters here
                  style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: "9966127822",
                    hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400),
                    filled: true,
                    fillColor: const Color(0xFFF2F4F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(70), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Icon(Icons.map_outlined, color: Colors.grey, size: 50)),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 59), side: const BorderSide(width: 1, color: Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          onPressed: _handleCancel,
          child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCCF656), minimumSize: const Size(double.infinity, 59), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          onPressed: _submitStepData,
          child: Text(_currentStep == 3 ? 'Submit Registration' : 'Next', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100, left: 16, right: 16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100, left: 16, right: 16),
      ),
    );
  }
  void _handleCancel() {
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
      case 3:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CancelRegistrationModal(
              onDontSave: () {
                print("Navigating back to the home screen.");
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SellHomeScreen()),
                      (route) => false, // This removes all routes behind SellHomeScreen.
                );              },
              onSaveToDraft: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SellerStatusScreen(
                      status: RegistrationStatus.resumeOnboarding,
                      resumeStep: _currentStep,
                    ),
                  ),
                      (route) => route.isFirst, // Removes all previous screens
                );
              },
              onContinue: () {
                // Custom action for "Continue"
                print("Dialog closed, user continues their task.");
                Navigator.of(context).pop();
              },
            );
          },
        );
        break;
    }
  }

}


class _ProgressStepIndicator extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  const _ProgressStepIndicator({ this.isActive = false, this.isCompleted = false });

  @override
  Widget build(BuildContext context) {
    final Color stepColor = (isActive || isCompleted) ? const Color(0xFFA2DC00) : const Color(0xFFDDDDDD);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle)),
        if (!isCompleted) Container(width: 18, height: 18, decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4))),
        if (isCompleted) const Icon(Icons.check, color: Colors.white, size: 20.0),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

