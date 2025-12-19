import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/home_page.dart'; // Import this
import 'change_info_screen.dart';
import 'change_password_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final UserProfileResponse? userProfile;
  final VoidCallback? onBack;

  const AccountDetailsScreen({super.key, this.userProfile, this.onBack});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String gender = "";
  String _selectedCountryCode = "+91";
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;

  List<String> _days = [];
  final List<String> _months = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  late List<String> _years;
  bool _isLoading = false;
  bool _isDobLocked = false;
  bool _isGenderLocked = false;

  UserProfileResponse? _currentProfile;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    _years = List.generate(100, (i) => (currentYear - i).toString());

    if (widget.userProfile == null) {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _updateDays();
    } else {
      _currentProfile = widget.userProfile!;
      final user = _currentProfile!.user;
      _nameController = TextEditingController(text: user.username);
      _phoneController = TextEditingController(text: user.phone);
      _emailController = TextEditingController(text: user.email);
      gender = user.gender;
      _selectedCountryCode = user.countryCode ?? "+91";
      if (gender.isNotEmpty) _isGenderLocked = true;
      if (user.dob != null && user.dob!.isNotEmpty) {
        try {
          DateTime date = DateTime.parse(user.dob!);
          _selectedYear = date.year.toString();
          _selectedMonth = _months[date.month - 1];
          _selectedDay = date.day.toString().padLeft(2, '0');
          _isDobLocked = true;
        } catch (e) {
          debugPrint("Error parsing DOB: $e");
        }
      }
      _updateDays();
    }
  }

  void _updateDays() {
    int year =
        int.tryParse(_selectedYear ?? DateTime.now().year.toString()) ??
        DateTime.now().year;
    int monthIndex =
        (_selectedMonth != null ? _months.indexOf(_selectedMonth!) : 0) + 1;
    int daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    setState(() {
      _days = List.generate(
        daysInMonth,
        (i) => (i + 1).toString().padLeft(2, '0'),
      );
      if (_selectedDay != null && int.parse(_selectedDay!) > daysInMonth)
        _selectedDay = null;
    });
  }

  void _onBackTap() {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  ImageProvider? get _currentImageProvider {
    if (_profileImageFile != null) return FileImage(_profileImageFile!);
    if (_currentProfile?.user.profilePic.url.isNotEmpty ?? false) {
      return NetworkImage(_currentProfile!.user.profilePic.url);
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null)
        setState(() => _profileImageFile = File(pickedFile.path));
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 80,
                backgroundImage: _currentImageProvider,
                child:
                    _currentImageProvider == null
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFA3DD00)),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFA3DD00),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentImageProvider != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    "Remove Photo",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImageFile = null;
                      // Note: Logic to remove network image might be needed depending on API
                    });
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _onBackTap,
        ),
        centerTitle: true,
        title: const Text(
          "Account Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child:
            _currentProfile == null
                ? const Center(
                  child: Text(
                    "User profile not available.",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
                : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _profileHeader(),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Colors.grey),
                              const SizedBox(height: 24),
                              _buildTextField("Name", _nameController),
                              const SizedBox(height: 16),
                              _buildLabel("Gender"),
                              const SizedBox(height: 8),
                              _genderSelector(),
                              const SizedBox(height: 16),
                              _buildLabel("Date of Birth"),
                              const SizedBox(height: 8),
                              _dateOfBirthFields(),
                              const SizedBox(height: 16),
                              _phoneField(),
                              const SizedBox(height: 16),
                              _buildTextField("Email", _emailController),
                              const SizedBox(height: 16),
                              _passwordField(userProfile: widget.userProfile!),
                              const SizedBox(height: 30),
                              _actionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Container(
                        color: Colors.black38,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _profileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _currentImageProvider,
              child:
                  _currentImageProvider == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImagePreviewDialog,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA3DD00),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.edit, color: Colors.black, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _emailController.text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  );
  Widget _buildTextField(String label, TextEditingController controller) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );

  Widget _passwordField({required UserProfileResponse userProfile}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel("Password"),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: "********",
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          suffix: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChangePasswordScreen(userProfile: userProfile),
                  ),
                ),
            child: const Text(
              "Change Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFA3DD00),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );

  Widget _genderSelector() {
    final options = {
      "Male": Icons.male,
      "Female": Icons.female,
      "Other": Icons.transgender,
    };
    return IgnorePointer(
      ignoring: _isGenderLocked,
      child: Opacity(
        opacity: _isGenderLocked ? 0.5 : 1.0,
        child: Row(
          children:
              options.entries.map((entry) {
                final isSelected = gender == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => gender = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFA3DD00)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            entry.value,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _dateOfBirthFields() => IgnorePointer(
    ignoring: _isDobLocked,
    child: Opacity(
      opacity: _isDobLocked ? 0.5 : 1.0,
      child: Row(
        children: [
          _dobDropdown(
            _days,
            _selectedDay,
            "DD",
            (v) => setState(() => _selectedDay = v),
          ),
          const SizedBox(width: 8),
          _dobDropdown(_months, _selectedMonth, "MM", (v) {
            setState(() {
              _selectedMonth = v;
              _updateDays();
            });
          }),
          const SizedBox(width: 8),
          _dobDropdown(_years, _selectedYear, "YYYY", (v) {
            setState(() {
              _selectedYear = v;
              _updateDays();
            });
          }),
        ],
      ),
    ),
  );

  Widget _dobDropdown(
    List<String> items,
    String? value,
    String hint,
    void Function(String?) onChanged,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _phoneField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel("Phone"),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CountryCodePicker(
              onChanged:
                  (c) => setState(
                    () => _selectedCountryCode = c.dialCode ?? "+91",
                  ),
              initialSelection: 'IN',
              favorite: const ['+91', 'IN'],
              showFlag: false,
              showDropDownButton: true,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter phone number',
                  counterText: "",
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _actionButtons() => Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onBackTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Color(0xFFA3DD00)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Cancel", style: TextStyle(fontSize: 16)),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA3DD00),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
        ),
      ),
    ],
  );

  void _onSavePressed() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedDay == null ||
        _selectedMonth == null ||
        _selectedYear == null ||
        gender.isEmpty) {
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text("Missing Fields"),
              content: const Text("Please fill in all details."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text("Confirm Changes"),
            content: const Text(
              "Are you sure you want to update your details?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  _handleSaveChanges();
                },
                child: const Text("Yes, Update"),
              ),
            ],
          ),
    );
  }

  void _handleSaveChanges() async {
    final newDob =
        "${_selectedYear!}-${(_months.indexOf(_selectedMonth!) + 1).toString().padLeft(2, '0')}-${_selectedDay!}";
    setState(() => _isLoading = true);
    try {
      await _apiService.updateUserProfile(
        name: _nameController.text.trim(),
        gender: gender,
        dob: newDob,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        countryCode: _selectedCountryCode,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
        _onBackTap();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
