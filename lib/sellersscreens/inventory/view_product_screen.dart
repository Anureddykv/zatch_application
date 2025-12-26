import 'package:flutter/material.dart';

import 'inventory_screen.dart';

class ViewProductScreen extends StatefulWidget {
  final Product product;

  const ViewProductScreen({super.key, required this.product});

  @override
  _ViewProductScreenState createState() => _ViewProductScreenState();
}

class _ViewProductScreenState extends State<ViewProductScreen> {
  String _selectedSize = 'L';
  int _selectedColorIndex = 1;
  int _currentImageIndex = 0;
  bool _isInfoTabSelected = true;

  final List<Color> _colors = [
    const Color(0xFF787676),
    const Color(0xFF433F40),
    const Color(0xFFFF7979),
    const Color(0xFFFFB979),
    const Color(0xFFB7FF79),
    const Color(0xFF79E6FF),
    const Color(0xFF798BFF),
    const Color(0xFFA579FF),
    const Color(0xFFFF79F1),
    const Color(0xFFE10E12),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverImageHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildTitleAndPrice(),
                      const SizedBox(height: 16),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildSizeSelector(),
                      const SizedBox(height: 24),
                      _buildColorSelector(),
                      const SizedBox(height: 24),
                      _buildInfoTabs(),
                      const SizedBox(height: 24),
                      if (_isInfoTabSelected) ...[
                        _buildInfoSection(
                          title: 'Info',
                          content:
                          'We work with monitoring programmes to ensure compliance with safety, health and quality standards for our products.',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          title: 'Info 2',
                          content:
                          'To keep your jackets and coats clean, you only need to freshen them up and go over them with a cloth or a clothes brush. If you need to dry clean a garment, look for a dry cleaner that uses technologies that are respectful of the environment.',
                        ),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              "Comments(113) section will be shown here.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 120), // Space for the bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingTopButtons(context),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSliverImageHeader() {
    return SliverAppBar(
      expandedHeight: 509.0,
      stretch: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.product.imageUrl,
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black],
                  stops: [0.4, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? const Color(0xFFCCF656)
                          : Colors.white.withOpacity(0.7),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTopButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circularButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
            Row(
              children: [
                _circularButton(icon: Icons.share, isTransparent: true),
                const SizedBox(width: 16),
                _circularButton(
                  icon: Icons.favorite,
                  isTransparent: true,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularButton(
      {required IconData icon,
        VoidCallback? onPressed,
        bool isTransparent = false,
        Color? color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isTransparent ? Colors.white.withOpacity(0.1) : Colors.white,
          shape: BoxShape.circle,
          border: isTransparent
              ? null
              : Border.all(color: const Color(0xFFDFDEDE), width: 1),
        ),
        child: Icon(icon, color: color ?? (isTransparent ? Colors.white : Colors.black), size: 24),
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Encode Sans',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '5.0 ',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF787676),
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '(7,932 reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Text(
          "${widget.product.cost}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Encode Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Its simple and elegant shape makes it perfect for those of you who like you who want minimalist clothes',
      style: TextStyle(
        color: Color(0xFF787676),
        fontSize: 12,
        height: 1.5,
        fontFamily: 'Encode Sans',
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Size',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: ['S', 'M', 'L', 'XL'].map((size) {
            bool isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF292526) : Colors.white,
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: const Color(0xFFDFDEDE), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color:
                      isSelected ? Colors.white : const Color(0xFF292526),
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: List.generate(_colors.length, (index) {
            bool isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _colors[index],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                        color: _colors[index].withOpacity(0.7),
                        blurRadius: 5,
                        spreadRadius: 1)
                  ]
                      : [],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab('Basic info', _isInfoTabSelected),
          _buildTab('Reviews', !_isInfoTabSelected),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isInfoTabSelected = title == 'Basic info';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 20,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () {

        },
        child: Container(
          height: 59,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.5, color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Center(
            child: Text(
              'Edit Product',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
