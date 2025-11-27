import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zatch_app/services/api_service.dart';

class PolicyScreen extends StatefulWidget {
  final String title;

  const PolicyScreen({super.key, required this.title});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final ApiService _api = ApiService();
  String? _htmlContent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  Future<void> _fetchPolicy() async {
    try {
      String content;
      if (widget.title.toLowerCase().contains("terms")) {
        content = await _api.getTermsAndConditions();
      } else {
        content = await _api.getPrivacyPolicy();
      }

      setState(() {
        _htmlContent = content;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _htmlContent = "<p>Failed to load ${widget.title}</p>";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Html(
          data: _htmlContent ?? "<p>No content available</p>",
        ),
      ),
    );
  }
}
