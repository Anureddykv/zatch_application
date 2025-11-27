import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ----------------- Models -----------------
// (No changes needed in your models)

class CardModel {
  final String brand;
  final String last4;
  CardModel({required this.brand, required this.last4});
}

class UpiModel {
  final String upiId;
  UpiModel({required this.upiId});
}

class WalletModel {
  final String name;
  final String? logoAsset;
  WalletModel({required this.name, this.logoAsset});
}

class PaymentData {
  List<CardModel> cards;
  List<UpiModel> upis;
  List<WalletModel> wallets;

  PaymentData({
    required this.cards,
    required this.upis,
    required this.wallets,
  });

  // Initial dummy data
  static PaymentData getDummy() {
    return PaymentData(
      cards: [
        CardModel(brand: "VISA", last4: "2143"),
        CardModel(brand: "MasterCard", last4: "5678"),
      ],
      upis: [
        UpiModel(upiId: "xyz@ybl"),
      ],
      wallets: [
        WalletModel(name: "Paytm"),
      ],
    );
  }
}


// ----------------- Main Screen (Refactored to StatefulWidget) -----------------

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // 1. Hold the payment data in the state
  late PaymentData _paymentData;
  Object? _selectedItem;

  // 2. State variables to track selection
  int? _selectedCardIndex;
  int? _selectedUpiIndex;
  int? _selectedWalletIndex;

  @override
  void initState() {
    super.initState();
    _paymentData = PaymentData.getDummy();
  }

  void _navigateAndAddCard() async {
    final newCard = await Navigator.push<CardModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddNewCardScreen()),
    );
    if (newCard != null && mounted) {
      setState(() {
        _paymentData.cards.add(newCard);
      });
    }
  }

  void _navigateAndAddUpi() async {
    final newUpi = await Navigator.push<UpiModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddUpiScreen()),
    );

    if (newUpi != null && mounted) {
      setState(() {
        _paymentData.upis.add(newUpi);
      });
    }
  }

  void _navigateAndAddWallet() async {
    final newWallet = await Navigator.push<WalletModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletScreen()),
    );

    if (newWallet != null && mounted) {
      setState(() {
        _paymentData.wallets.add(newWallet);
      });
    }
  }


  // --- UI Widget Builders ---

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _cardTile(CardModel card, int index) => GestureDetector(
    onTap: () => setState(() {
      _selectedCardIndex = index;
      _selectedUpiIndex = null;
      _selectedWalletIndex = null;
    }),
    child: Card(
      // Highlight if selected
      color: _selectedCardIndex == index
          ? const Color(0xFFE8F5E9)
          : const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: _selectedCardIndex == index
                  ? Colors.green
                  : Colors.transparent,
              width: 1.5)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.blue),
        title: Text('${card.brand} **** **** **** ${card.last4}'),
        trailing: _selectedCardIndex == index
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );

  Widget _upiTile(UpiModel upi, int index) => GestureDetector(
    onTap: () => setState(() {
      _selectedUpiIndex = index;
      _selectedCardIndex = null;
      _selectedWalletIndex = null;
    }),
    child: Card(
      color: _selectedUpiIndex == index
          ? const Color(0xFFE8F5E9)
          : const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: _selectedUpiIndex == index
                  ? Colors.green
                  : Colors.transparent,
              width: 1.5)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading:
        const Icon(Icons.account_balance_wallet, color: Colors.green),
        title: Text(upi.upiId),
        trailing: _selectedUpiIndex == index
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );

  Widget _walletTile(WalletModel wallet, int index) => GestureDetector(
    onTap: () => setState(() {
      _selectedWalletIndex = index;
      _selectedCardIndex = null;
      _selectedUpiIndex = null;
    }),
    child: Card(
      color: _selectedWalletIndex == index ? const Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: _selectedWalletIndex == index
                ? Colors.green
                : const Color(0xFFF2F2F2),
            width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: wallet.logoAsset != null
            ? SizedBox(
          width: 40,
          height: 24,
          child: Image.network(wallet.logoAsset!, fit: BoxFit.contain),
        )
            : const Icon(Icons.account_balance_wallet),
        title: Text(wallet.name),
        trailing: _selectedWalletIndex == index
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );

  Widget _addButton(String text, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.black,
          backgroundColor: const Color(0xFFF7FFDF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.add, color: Colors.black, size: 20),
        onPressed: onPressed,
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Payment Methods"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100), // Prevent overlap with FAB
              children: [
                _sectionTitle('Saved Cards'),
                // Use asMap().entries.map to get both the item and its index
                ..._paymentData.cards
                    .asMap()
                    .entries
                    .map((entry) => _cardTile(entry.value, entry.key)),
                _addButton('Add New Card', _navigateAndAddCard),

                _sectionTitle('UPI'),
                ..._paymentData.upis
                    .asMap()
                    .entries
                    .map((entry) => _upiTile(entry.value, entry.key)),
                _addButton('Add New UPI', _navigateAndAddUpi),

                _sectionTitle('Wallets'),
                ..._paymentData.wallets
                    .asMap()
                    .entries
                    .map((entry) => _walletTile(entry.value, entry.key)),
                _addButton('Add New Wallet', _navigateAndAddWallet),
              ],
            ),
          ),
        ],
      ),
      // Use a floating button at the bottom for the final action
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCF656), // A vibrant color
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Logic to confirm selection and pop
              Navigator.of(context).pop();
            },
            child: const Text('Confirm Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}


// ----------------- Add Card Screen -----------------

class AddNewCardScreen extends StatefulWidget {  const AddNewCardScreen({super.key});

@override
State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _canProceed = false;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to each controller to trigger validation in real-time.
    _cardNumberController.addListener(_validateForm);
    _expiryController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Clean up controllers and remove listeners to prevent memory leaks.
    _cardNumberController.removeListener(_validateForm);
    _expiryController.removeListener(_validateForm);
    _cvvController.removeListener(_validateForm);
    _nameController.removeListener(_validateForm);

    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  /// Checks if all fields are valid and updates the button's enabled state.
  void _validateForm() {
    // A small delay ensures the text field's value is updated before validation runs.
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      final isValid = _formKey.currentState?.validate() ?? false;
      if (isValid != _canProceed) {
        setState(() {
          _canProceed = isValid;
        });
      }
    });
  }

  /// --- CORRECTED LOGIC ---
  /// This function now creates a CardModel and passes it back to the previous screen.
  void _onProceed() {
    if (_formKey.currentState!.validate()) {
      // 1. Create a new card model from the form data.
      final newCard = CardModel(
        // You can add logic to detect brand from the card number.
        brand: "Visa",
        // Get the last 4 digits for display.
        last4: _cardNumberController.text.length > 4
            ? _cardNumberController.text.substring(_cardNumberController.text.length - 4)
            : "0000",
      );

      // 2. Pop the screen and pass the `newCard` object as the result.
      Navigator.of(context).pop(newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Add New Card',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          // `onChanged` is less reliable here; using listeners is better.
          // onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Card Number Field
                      _buildTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        hint: 'Enter Card Number',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16), // Restrict to 16 digits
                        ],
                        validator: (value) {
                          if (value == null || value.length != 16) {
                            return 'Please enter a valid 16-digit card number.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Expiry and CVV Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryController,
                              label: 'Valid Through',
                              hint: 'MM/YY',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5), // "MM/YY" is 5 chars
                                ExpiryDateFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.length != 5) {
                                  return 'Enter valid MM/YY';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _cvvController,
                              label: 'CVV',
                              hint: 'Enter CVV',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3), // Restrict to 3 digits
                              ],
                              validator: (value) {
                                if (value == null || value.length != 3) {
                                  return 'Enter a 3-digit CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Name on Card Field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name on Card',
                        hint: 'Enter Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the name on the card.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Card Nickname Field
                      _buildTextField(
                        controller: _nicknameController,
                        label: 'Card Nick Name (Optional)',
                        hint: 'Enter Card Nick Name',
                      ),
                    ],
                  ),
                ),
              ),
              // Proceed Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  // CORRECTED: Call the `_onProceed` method here.
                  onPressed: _canProceed ? _onProceed : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFCCF656),
                    disabledBackgroundColor: const Color(0xFFF2F4F5),
                    disabledForegroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget to build consistently styled text fields.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFABABAB),
              fontSize: 14,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          validator: validator,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF616161),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(70),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
        ),
      ],
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 2 && oldValue.text.length == 1) {
      newText += '/';
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


// ----------------- Add UPI Screen -----------------

class AddUpiScreen extends StatefulWidget {
  const AddUpiScreen({super.key});

  @override
  State<AddUpiScreen> createState() => _AddUpiScreenState();
}

class _AddUpiScreenState extends State<AddUpiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiIdController = TextEditingController();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    // Listen to the controller to enable/disable the button
    _upiIdController.addListener(() {
      final canProceed = _upiIdController.text.isNotEmpty;
      if (canProceed != _canProceed) {
        setState(() {
          _canProceed = canProceed;
        });
      }
    });
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  void _onProceed() {
    // Validate the form before proceeding
    if (_formKey.currentState!.validate()) {
      final newUpi = UpiModel(upiId: _upiIdController.text);
      // Pop the screen and return the new UPI model
      Navigator.of(context).pop(newUpi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Add New UPI',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
      // Use a Column layout with a Spacer to push the button to the bottom
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // UPI ID Text Field
              _buildTextField(
                controller: _upiIdController,
                label: 'Enter your UPI ID',
                hint: 'Enter UPI ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'UPI ID cannot be empty.';
                  }
                  // Basic validation for UPI format
                  if (!value.contains('@')) {
                    return 'Please enter a valid UPI ID (e.g., name@bank)';
                  }
                  return null;
                },
              ),
              const Spacer(), // Pushes the button to the bottom
              // Proceed Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: _canProceed ? _onProceed : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFCCF656),
                    disabledBackgroundColor: const Color(0xFFF2F4F5),
                    disabledForegroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget to build the styled text field from your Figma design.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFABABAB),
              fontSize: 14,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF616161),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F4F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(70),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
        ),
      ],
    );
  }
}

// ----------------- Add Wallet Screen -----------------

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final PageController _pageController = PageController();
  final _phoneController = TextEditingController();

  void _navigateToOtpStep() {
    // Navigate to the OTP screen after phone number is entered
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onVerificationSuccess() {
    // When OTP is correct, create the wallet model and pop back
    final newWallet = WalletModel(name: "PhonePe"); // Or any other linked wallet
    Navigator.of(context).pop(newWallet);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable swiping
      children: [
        // --- Page 1: Enter Phone Number ---
        ConnectPhonePeScreen(
          phoneController: _phoneController,
          onProceed: _navigateToOtpStep,
        ),
        // --- Page 2: Enter OTP ---
        OtpVerificationScreen(
          onProceed: _onVerificationSuccess,
        ),
      ],
    );
  }
}


// ----------------- Screen 1: Connect PhonePe Wallet -----------------

class ConnectPhonePeScreen extends StatefulWidget {
  final TextEditingController phoneController;
  final VoidCallback onProceed;

  const ConnectPhonePeScreen({
    super.key,
    required this.phoneController,
    required this.onProceed,
  });

  @override
  State<ConnectPhonePeScreen> createState() => _ConnectPhonePeScreenState();
}

class _ConnectPhonePeScreenState extends State<ConnectPhonePeScreen> {
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    widget.phoneController.addListener(() {
      final canProceed = widget.phoneController.text.length == 10;
      if (canProceed != _canProceed) {
        setState(() => _canProceed = canProceed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'Connect PhonePe Wallet'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter Phone number linked with\nPhonePe',
              style: TextStyle(
                color: Color(0xFF121111),
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: widget.phoneController,
              label: 'Phone Number',
              hint: 'Enter PhonePe Number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const Spacer(),
            _buildProceedButton(
              onPressed: _canProceed ? widget.onProceed : null,
            ),
          ],
        ),
      ),
    );
  }
}


// ----------------- Screen 2: OTP Verification -----------------

class OtpVerificationScreen extends StatelessWidget {
  final VoidCallback onProceed;

  const OtpVerificationScreen({super.key, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd manage the state of the OTP fields
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'OTP Verification'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter the 4-digit OTP received on your mobile number',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            // OTP Input Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _otpBox(),
                _otpBox(),
                _otpBox(),
                _otpBox(),
              ],
            ),
            const SizedBox(height: 40),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Didn\'t receive OTP ? '),
                  TextSpan(
                    text: 'Resend',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    // recognizer: TapGestureRecognizer()..onTap = () => print("Resend OTP"),
                  ),
                  const TextSpan(text: ' in 30 sec'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            _buildProceedButton(
              // In a real app, this would be enabled after OTP is filled
              onPressed: onProceed,
            ),
          ],
        ),
      ),
    );
  }

  // OTP input box widget
  Widget _otpBox() {
    return SizedBox(
      width: 65,
      height: 60,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF91C400), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF91C400), width: 1.5),
          ),
        ),
      ),
    );
  }
}


// --- Reusable Helper Widgets ---

AppBar _buildAppBar(BuildContext context, String title) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF121111),
        fontSize: 16,
        fontFamily: 'Encode Sans',
        fontWeight: FontWeight.w600,
      ),
    ),
    leading: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFABABAB),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF616161),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFFF2F4F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(70),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        ),
      ),
    ],
  );
}

Widget _buildProceedButton({required VoidCallback? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFFCCF656),
        disabledBackgroundColor: const Color(0xFFF2F4F5),
        disabledForegroundColor: Colors.grey,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Proceed',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Encode Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

