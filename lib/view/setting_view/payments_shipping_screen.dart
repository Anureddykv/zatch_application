import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/coupon_model.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/coupon_apply_screen.dart';
import 'package:zatch_app/view/order_view/order_place_screen.dart';
import 'package:zatch_app/view/setting_view/account_details_screen.dart';
import 'package:zatch_app/view/setting_view/add_new_address_screen.dart';
import 'package:zatch_app/view/setting_view/payment_method_screen.dart';

class CheckoutOrPaymentsScreen extends StatefulWidget {
  final bool isCheckout;
  final List<cart_model.CartItemModel>? selectedItems;
  final double? itemsTotalPrice;
  final double? shippingFee;
  final double? subTotalPrice;

  const CheckoutOrPaymentsScreen({
    super.key,
    this.isCheckout = true,
    this.selectedItems,
    this.itemsTotalPrice,
    this.shippingFee,
    this.subTotalPrice,
  });

  @override
  State<CheckoutOrPaymentsScreen> createState() =>
      _CheckoutOrPaymentsScreenState();
}

class _CheckoutOrPaymentsScreenState extends State<CheckoutOrPaymentsScreen> {
  int selectedAddressIndex = 0;
  int selectedPayment = 0;
  UserProfileResponse? userProfile;

  // Using stateful list for dynamic removal
  final List<Address> _addresses = [
    Address(
      id: '1',
      title: "Home",
      fullAddress: "A-403 Mantri Celestia, Financial District, Hyderabad",
      phone: "+91 98765 43210",
      icon: Icons.home_outlined,
    ),
    Address(
      id: '2',
      title: "Office",
      fullAddress: "Waverock Building, Nanakramguda, Hyderabad",
      phone: "+91 99887 76655",
      icon: Icons.apartment_outlined,
    ),
    Address(
      id: '3',
      title: "Other",
      fullAddress: "Lorem ipsum street, Madhapur, Hyderabad",
      phone: "+91 88776 65544",
      icon: Icons.location_on_outlined,
    ),
  ];

  Coupon? appliedCoupon;
  double discountAmount = 0.0;
  late double finalSubTotal;
  Object? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    finalSubTotal = widget.subTotalPrice ?? 0.0;
    // Pre-select office to match figma
    int officeIndex = _addresses.indexWhere((a) => a.title == "Office");
    if (officeIndex != -1) {
      selectedAddressIndex = officeIndex;
    }
  }

  void _selectPaymentMethod() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedPaymentMethod = result;
      });
    }
  }

  /// Applies the selected coupon and updates the totals.
  void _applyCoupon(Coupon coupon) {
    setState(() {
      appliedCoupon = coupon;
      // Calculate discount based on the items' total price before shipping
      double calculatedDiscount =
          (widget.itemsTotalPrice ?? 0.0) * (coupon.discountPercentage / 100);
      discountAmount = calculatedDiscount;
      // Recalculate the final subtotal
      finalSubTotal = (widget.subTotalPrice ?? 0.0) - discountAmount;
    });
  }

  /// Removes the applied coupon and resets the discount.
  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      discountAmount = 0.0;
      // Restore the original subtotal
      finalSubTotal = widget.subTotalPrice ?? 0.0;
    });
  }

  /// Navigates to the Coupon screen and handles the result.
  void _navigateToCouponScreen() async {
    // The result can be a Coupon object or null
    final result = await Navigator.push<Coupon>(
      context,
      MaterialPageRoute(builder: (_) => const CouponApplyScreen()),
    );

    // If the user selected a coupon and tapped "Apply"
    if (result != null) {
      _applyCoupon(result);
    }
  }

  // --- Dialog for removing item ---
  Future<void> _showRemoveItemDialog(cart_model.CartItemModel item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item?'),
          content: const Text(
            'Are you sure you want to remove this item from your cart?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
              onPressed: () {
                setState(() {
                  widget.selectedItems?.remove(item);
                  // Optionally, recalculate totals here if needed
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(32),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isCheckout) ...[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- List of Cart Items ---
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.selectedItems?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = widget.selectedItems![index];
                            return _cartItem(item);
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 22),
                        ),
                        const SizedBox(height: 22),

                        // --- Shipping Information ---
                        _shippingInfo(
                          itemCount: widget.selectedItems?.length ?? 0,
                          itemsTotal: widget.itemsTotalPrice ?? 0.0,
                          shipping: widget.shippingFee ?? 0.0,
                          discount: discountAmount,
                          subTotal: finalSubTotal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _contactDetailsSection(),
                    const SizedBox(height: 36),
                  ],
                  const Text(
                    'Select Location',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return _addressTile(
                        address: address,
                        isSelected: selectedAddressIndex == index,
                        onTap:
                            () => setState(() => selectedAddressIndex = index),
                        onEdit: () async {
                          final updatedAddress = await Navigator.push<Address>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AddNewAddressScreen(
                                    addressToEdit: address,
                                  ),
                            ),
                          );
                          if (updatedAddress != null) {
                            setState(() {
                              final index = _addresses.indexWhere(
                                (a) => a.id == updatedAddress.id,
                              );
                              if (index != -1) {
                                _addresses[index] = updatedAddress;
                              }
                            });
                          }
                        },

                        onRemove: () {
                          setState(() {
                            _addresses.removeAt(index);
                            if (selectedAddressIndex >= _addresses.length &&
                                _addresses.isNotEmpty) {
                              selectedAddressIndex = _addresses.length - 1;
                            }
                          });
                        },
                      );
                    },
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                  ),
                  const SizedBox(height: 12),
                  _addNewButton("Add New Address", () async {
                    final newAddress = await Navigator.push<Address>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewAddressScreen(),
                      ),
                    );
                    if (newAddress != null) {
                      setState(() {
                        _addresses.add(newAddress);
                      });
                    }
                  }),

                  const SizedBox(height: 36),

                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      color: Color(0xFF121111),
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _paymentTile(0, "VISA", "2143"),
                  const SizedBox(height: 16),
                  _buildPaymentSection(),
                  if (widget.isCheckout) ...[
                    const SizedBox(height: 36),
                    const Text(
                      'Coupon Code',
                      style: TextStyle(
                        color: Color(0xFF121111),
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCouponSection(),
                  ],
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
          // --- PAY BUTTON ---
          if (widget.isCheckout)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => OrderPlacedScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFCCF656),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Pay',
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
    );
  }

  Widget _buildCouponSection() {
    bool isApplied = appliedCoupon != null;

    if (isApplied) {
      // --- UI WHEN A COUPON IS APPLIED ---
      return Container(
        height: 67,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.5, color: Colors.green),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "'${appliedCoupon!.code}' Applied!",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You saved ${discountAmount.toStringAsFixed(2)} ₹",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Encode Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _removeCoupon,
              child: const Text(
                "Remove",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // --- UI TO APPLY A NEW COUPON ---
      return InkWell(
        onTap: _navigateToCouponScreen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 67,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFD3D3D3)),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Apply Coupon Code',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8B0000)),
            ],
          ),
        ),
      );
    }
  }

  Widget _cartItem(cart_model.CartItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            item.image,
            width: 57,
            height: 57,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.variant.color ?? item.variant.shade ?? "",
                style: const TextStyle(
                  color: Color(0xFF787676),
                  fontSize: 10,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.price.toStringAsFixed(2)} ₹',
                style: const TextStyle(
                  color: Color(0xFF292526),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.more_horiz, size: 24, color: Color(0xFF292526)),
            const SizedBox(height: 9),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quantityButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (item.quantity > 1) {
                      setState(() {
                        final index = widget.selectedItems!.indexWhere(
                          (i) => i.id == item.id,
                        );

                        if (index != -1) {
                          widget
                              .selectedItems![index] = cart_model.CartItemModel(
                            id: item.id,
                            productId: item.productId,
                            sellerId: item.sellerId,
                            name: item.name,
                            description: item.description, // ✔ FIXED
                            price: item.price,
                            discountedPrice: item.discountedPrice,
                            image: item.image,
                            images: item.images, // ✔ FIXED
                            variant: item.variant,
                            selectedVariant: item.selectedVariant,
                            quantity: item.quantity - 1, // ✔ FIXED
                            category: item.category,
                            subCategory: item.subCategory,
                            productCategory: item.productCategory,
                            lineTotal:
                                (item.discountedPrice * (item.quantity + 1))
                                    .round(),
                          );
                        }
                      });
                    } else {
                      _showRemoveItemDialog(item);
                    }
                  },
                ),
                const SizedBox(width: 12),

                // ✔ FIXED quantity text
                SizedBox(
                  width: 20,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF292526),
                      fontSize: 14,
                      fontFamily: 'Encode Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                _quantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      final index = widget.selectedItems!.indexWhere(
                        (i) => i.id == item.id,
                      );

                      if (index != -1) {
                        widget.selectedItems![index] = cart_model.CartItemModel(
                          id: item.id,
                          productId: item.productId,
                          sellerId: item.sellerId,
                          name: item.name,
                          description: item.description, // ✔ FIXED
                          price: item.price,
                          discountedPrice: item.discountedPrice,
                          image: item.image,
                          images: item.images, // ✔ FIXED
                          variant: item.variant,
                          selectedVariant: item.selectedVariant,
                          quantity: item.quantity + 1, // ✔ FIXED
                          category: item.category,
                          subCategory: item.subCategory,
                          productCategory: item.productCategory,
                          lineTotal:
                              (item.discountedPrice * (item.quantity + 1))
                                  .round(),
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _shippingInfo({
    required int itemCount,
    required double itemsTotal,
    required double shipping,
    required double discount,
    required double subTotal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Information',
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceRow(
          'Total ($itemCount items)',
          '${itemsTotal.toStringAsFixed(2)} ₹',
        ),
        const SizedBox(height: 12),
        _buildPriceRow('Shipping Fee', '${shipping.toStringAsFixed(2)} ₹'),
        const SizedBox(height: 12),
        _buildPriceRow(
          'Discount',
          '-${discount.toStringAsFixed(2)} ₹',
          valueColor: Colors.green,
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFCBCBCB), thickness: 1),
        const SizedBox(height: 12),
        _buildPriceRow(
          'Sub Total',
          '${subTotal.toStringAsFixed(2)} ₹',
          isBold: true,
        ),
        const Divider(color: Color(0xFFCBCBCB), thickness: 1),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF292526),
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF121111),
            fontSize: isBold ? 16 : 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _contactDetailsSection() {
    final email = userProfile?.user.email ?? 'd.v.a.v.raju@gmail.com';
    final phone = userProfile?.user.phone ?? '+91 9966127833';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
            height: 1.14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email',
                style: TextStyle(
                  color: Color(0xFFABABAB),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.71,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email ?? 'd.v.a.v.raju@gmail.com',
                style: TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Phone Number',
                style: TextStyle(
                  color: Color(0xFFABABAB),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.71,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                phone ?? '+91 9966127833',
                style: TextStyle(
                  color: Color(0xFF121111),
                  fontSize: 14,
                  fontFamily: 'Encode Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addressTile({
    required Address address,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) {
    return Dismissible(
      key: Key(address.id),
      direction:
          DismissDirection.horizontal, // Allow swiping in both directions

      background: Container(
        decoration: BoxDecoration(
          color: Color(0xFFCCF656),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swiped Right to Edit
          onEdit();
          return false; // Prevent the item from being dismissed
        } else {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Delete"),
                content: const Text(
                  "Are you sure you want to remove this address?",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onRemove(); // Call remove callback if confirmed
                    },
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: isSelected ? 2 : 1,
                color:
                    isSelected
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFD3D3D3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 65,
                height: 66,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF2F2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Icon(address.icon, size: 30, color: Colors.black54),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.title,
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.fullAddress},${address.phone}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8D8D8D),
                        fontSize: 12,
                        fontFamily: 'Encode Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              _customRadioButton(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(int index, String type, String digits) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: RadioListTile(
        value: index,
        groupValue: selectedPayment,
        onChanged: (val) => setState(() => selectedPayment = val!),
        activeColor: Colors.black,
        title: Text("$type **** **** $digits"),
        secondary: const Icon(Icons.credit_card, color: Colors.blue),
      ),
    );
  }

  Widget _customRadioButton(bool isSelected) {
    return Container(
      width: 18,
      height: 18,
      decoration: ShapeDecoration(
        shape: OvalBorder(
          side: BorderSide(
            width: isSelected ? 2 : 1,
            color:
                isSelected ? const Color(0xFF2C2C2C) : const Color(0xFFD3D3D3),
          ),
        ),
      ),
      child:
          isSelected
              ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF2C2C2C),
                    shape: OvalBorder(),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _addNewButton(String text, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFDAFF00)),
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFFDAFF00).withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPaymentSection() {
    // Case 1: A payment method has been selected.
    if (_selectedPaymentMethod != null) {
      String title = 'Unknown Payment Method';
      IconData icon = Icons.credit_card;
      Color iconColor = Colors.grey;

      // Determine the type of the selected method and set the details.
      if (_selectedPaymentMethod is CardModel) {
        final card = _selectedPaymentMethod as CardModel;
        title = '${card.brand} **** ${card.last4}';
        icon = Icons.credit_card;
        iconColor = Colors.blue;
      } else if (_selectedPaymentMethod is UpiModel) {
        final upi = _selectedPaymentMethod as UpiModel;
        title = upi.upiId;
        icon = Icons.account_balance_wallet;
        iconColor = Colors.green;
      } else if (_selectedPaymentMethod is WalletModel) {
        final wallet = _selectedPaymentMethod as WalletModel;
        title = wallet.name;
        icon = Icons.account_balance_wallet;
        iconColor = Colors.orange;
      }

      // Return a styled tile showing the selected method.
      return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: TextButton(
            onPressed: _selectPaymentMethod, // Allow user to change selection
            child: const Text(
              "Change",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    // Case 2: No payment method is selected yet.
    else {
      return _addNewButton("Choose Payment Method", _selectPaymentMethod);
    }
  }
}
