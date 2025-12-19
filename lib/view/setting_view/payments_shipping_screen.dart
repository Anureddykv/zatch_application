import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zatch_app/model/CartApiResponse.dart' as cart_model;
import 'package:zatch_app/model/address_model.dart';
import 'package:zatch_app/model/coupon_model.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/services/api_service.dart';
import 'package:zatch_app/view/coupon_apply_screen.dart';
import 'package:zatch_app/view/home_page.dart'; // Import this
import 'package:zatch_app/view/order_view/order_place_screen.dart';
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
  final ApiService _apiService = ApiService();
  int selectedAddressIndex = 0;

  UserProfileResponse? userProfile;
  bool isLoading = true;

  double currentItemsTotal = 0.0;
  late double finalSubTotal;

  List<Address> _addresses = [];

  Coupon? appliedCoupon;
  double discountAmount = 0.0;
  Object? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    double calculatedItemsTotal = 0.0;
    if (widget.selectedItems != null) {
      for (var item in widget.selectedItems!) {
        calculatedItemsTotal += (item.price * item.quantity);
      }
    }
    currentItemsTotal = widget.itemsTotalPrice ?? calculatedItemsTotal;
    finalSubTotal = widget.subTotalPrice ?? (currentItemsTotal + (widget.shippingFee ?? 0.0));
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      try { userProfile = await _apiService.getUserProfile(); } catch (e) { debugPrint("Warning: Failed to fetch profile: $e"); }
      try {
        final fetchedAddresses = await _apiService.getAllAddresses();
        if (mounted) {
          setState(() {
            _addresses = fetchedAddresses;
            if (_addresses.isNotEmpty) {
              int defaultIndex = _addresses.indexWhere((a) => a.type.toLowerCase() == "home");
              if (defaultIndex == -1) defaultIndex = _addresses.indexWhere((a) => a.type.toLowerCase() == "office");
              selectedAddressIndex = (defaultIndex != -1) ? defaultIndex : 0;
            }
          });
        }
      } catch (e) { debugPrint("Warning: Failed to fetch addresses: $e"); if (mounted) setState(() => _addresses = []); }
      _selectedPaymentMethod = null;
    } catch (e) { debugPrint("Global Error in Checkout: $e"); } finally { if (mounted) setState(() => isLoading = false); }
  }

  void _onBackTap() {
    if (homePageKey.currentState != null) {
      homePageKey.currentState!.closeSubScreen();
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Checkout?'),
        content: const Text('Are you sure you want to leave? Your progress may be lost.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return confirm ?? false;
  }

  void _selectPaymentMethod() async {
    final result = await Navigator.push<Object>(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
    if (result != null && mounted) setState(() => _selectedPaymentMethod = result);
  }

  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      discountAmount = 0.0;
      finalSubTotal = currentItemsTotal + (widget.shippingFee ?? 0.0);
    });
  }

  void _navigateToCouponScreen() async {
    final List<String> productIds = widget.selectedItems?.map((item) => item.productId).toList() ?? [];
    final result = await Navigator.push<Coupon>(context, MaterialPageRoute(builder: (_) => CouponApplyScreen(cartTotal: currentItemsTotal, productIds: productIds)));
    if (result != null) _applyCoupon(result);
  }

  void _applyCoupon(Coupon coupon) {
    setState(() {
      appliedCoupon = coupon;
      double calculatedDiscount = 0.0;
      if (coupon.discountType == 'fixed') { calculatedDiscount = coupon.discountValue; } else {
        calculatedDiscount = currentItemsTotal * (coupon.discountValue / 100);
        if (coupon.maxDiscount != null && calculatedDiscount > coupon.maxDiscount!) calculatedDiscount = coupon.maxDiscount!;
      }
      if (calculatedDiscount > currentItemsTotal) calculatedDiscount = currentItemsTotal;
      discountAmount = calculatedDiscount;
      finalSubTotal = currentItemsTotal + (widget.shippingFee ?? 0.0) - discountAmount;
    });
  }

  void _recalculateTotals() {
    double tempTotal = 0.0;
    if (widget.selectedItems != null) { for (var item in widget.selectedItems!) { tempTotal += item.price * item.quantity; } }
    double newDiscount = 0.0;
    if (appliedCoupon != null) {
      if (appliedCoupon!.discountType == 'fixed') { newDiscount = appliedCoupon!.discountValue; } else {
        newDiscount = tempTotal * (appliedCoupon!.discountValue / 100);
        if (appliedCoupon!.maxDiscount != null && newDiscount > appliedCoupon!.maxDiscount!) newDiscount = appliedCoupon!.maxDiscount!;
      }
      if (newDiscount > tempTotal) newDiscount = tempTotal;
    }
    setState(() {
      currentItemsTotal = tempTotal;
      discountAmount = newDiscount;
      finalSubTotal = tempTotal + (widget.shippingFee ?? 0.0) - newDiscount;
    });
  }

  Future<void> _showRemoveItemDialog(cart_model.CartItemModel item) async {
    return showDialog<void>(
      context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item?'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Remove'), onPressed: () { setState(() { widget.selectedItems?.remove(item); _recalculateTotals(); }); Navigator.of(context).pop(); }),
          ],
        );
      },
    );
  }
  Future<void> _deleteAddress(String addressId) async {
    try { await _apiService.deleteAddress(addressId); _fetchInitialData(); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete address: $e"))); }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop) _onBackTap();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.white, elevation: 0, centerTitle: true,
          title: const Text('Checkout', style: TextStyle(color: Color(0xFF121111), fontSize: 16, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
          leading: Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () async {
                final bool shouldPop = await _onWillPop();
                if (shouldPop) _onBackTap();
              },
              borderRadius: BorderRadius.circular(32),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFCCF656)))
            : Column(
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
                          ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: widget.selectedItems?.length ?? 0, itemBuilder: (context, index) => _cartItem(widget.selectedItems![index]), separatorBuilder: (context, index) => const SizedBox(height: 22)),
                          const SizedBox(height: 22),
                          _shippingInfo(itemCount: widget.selectedItems?.length ?? 0, itemsTotal: currentItemsTotal, shipping: widget.shippingFee ?? 0.0, discount: discountAmount, subTotal: finalSubTotal),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _contactDetailsSection(),
                      const SizedBox(height: 36),
                    ],
                    const Text('Select Location', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    if (_addresses.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("No addresses found. Please add one.")))
                    else ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _addresses.length, itemBuilder: (context, index) => _addressTile(address: _addresses[index], isSelected: selectedAddressIndex == index, onTap: () => setState(() => selectedAddressIndex = index), onEdit: () async { final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddNewAddressScreen(addressToEdit: _addresses[index]))); if (result == true) _fetchInitialData(); }, onRemove: () => _deleteAddress(_addresses[index].id)), separatorBuilder: (c, i) => const SizedBox(height: 12)),
                    const SizedBox(height: 12),
                    _addNewButton("Add New Address", () async { final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddNewAddressScreen())); if (result == true) _fetchInitialData(); }),
                    const SizedBox(height: 36),
                    const Text('Choose Payment Method', style: TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildPaymentSection(),
                    if (widget.isCheckout) ...[
                      const SizedBox(height: 36),
                      const Text('Coupon Code', style: TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _buildCouponSection(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (widget.isCheckout)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_addresses.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add and select a shipping address."))); return; }
                    if (_selectedPaymentMethod == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a payment method."))); return; }
                    final selectedAddress = _addresses[selectedAddressIndex];
                    setState(() => isLoading = true);
                    try {
                      final List<Map<String, dynamic>> orderItems = widget.selectedItems?.map((item) => { 'productId': item.productId, 'quantity': item.quantity }).toList() ?? [];
                      final response = await _apiService.createOrder(addressId: selectedAddress.id, paymentMethod: "cod", buyerNote: "Please deliver before 5 PM", items:orderItems);
                      String? orderId; if (response['order'] != null && response['order']['_id'] != null) orderId = response['order']['_id'];
                      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => OrderPlacedScreen(orderId: orderId)), (route) => false);
                    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to place order: $e"), backgroundColor: Colors.red)); } finally { if (mounted) setState(() => isLoading = false); }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFFCCF656), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('Pay', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    if (appliedCoupon != null) {
      return Container(height: 67, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: const BorderSide(width: 1.5, color: Colors.green), borderRadius: BorderRadius.circular(20))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("'${appliedCoupon!.code}' Applied!", style: const TextStyle(color: Colors.green, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text("You saved ${discountAmount.toStringAsFixed(2)} ₹", style: const TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500))]), TextButton(onPressed: _removeCoupon, child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)))]));
    } else {
      return InkWell(onTap: _navigateToCouponScreen, borderRadius: BorderRadius.circular(20), child: Container(height: 67, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFFD3D3D3)), borderRadius: BorderRadius.circular(20))), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('Apply Coupon Code', style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)), Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8B0000))])));
    }
  }

  Widget _cartItem(cart_model.CartItemModel item) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(item.image, width: 57, height: 57, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 57, height: 57, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)))), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(item.variant.color ?? item.variant.shade ?? "", style: const TextStyle(color: Color(0xFF787676), fontSize: 10, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400)), const SizedBox(height: 4), Text('${item.price.toStringAsFixed(2)} ₹', style: const TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [PopupMenuButton<String>(icon: const Icon(Icons.more_horiz, size: 24, color: Color(0xFF292526)), onSelected: (value) { if (value == 'remove') _showRemoveItemDialog(item); }, itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[const PopupMenuItem<String>(value: 'remove', child: Text('Remove Item'))]), const SizedBox(height: 9), Row(mainAxisSize: MainAxisSize.min, children: [_quantityButton(icon: Icons.remove, onPressed: () { if (item.quantity > 1) { setState(() { final index = widget.selectedItems!.indexWhere((i) => i.id == item.id); if (index != -1) { final old = widget.selectedItems![index]; widget.selectedItems![index] = cart_model.CartItemModel(id: old.id, productId: old.productId, sellerId: old.sellerId, name: old.name, description: old.description, price: old.price, discountedPrice: old.discountedPrice, image: old.image, images: old.images, variant: old.variant, selectedVariant: old.selectedVariant, quantity: old.quantity - 1, category: old.category, subCategory: old.subCategory, productCategory: old.productCategory, lineTotal: (old.discountedPrice * (old.quantity - 1)).round()); _recalculateTotals(); } }); } else { _showRemoveItemDialog(item); } }), const SizedBox(width: 12), ConstrainedBox(constraints: const BoxConstraints(minWidth: 20), child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600))), const SizedBox(width: 12), _quantityButton(icon: Icons.add, onPressed: () { setState(() { final index = widget.selectedItems!.indexWhere((i) => i.id == item.id); if (index != -1) { final old = widget.selectedItems![index]; widget.selectedItems![index] = cart_model.CartItemModel(id: old.id, productId: old.productId, sellerId: old.sellerId, name: old.name, description: old.description, price: old.price, discountedPrice: old.discountedPrice, image: old.image, images: old.images, variant: old.variant, selectedVariant: old.selectedVariant, quantity: old.quantity + 1, category: old.category, subCategory: old.subCategory, productCategory: old.productCategory, lineTotal: (old.discountedPrice * (old.quantity + 1)).round()); _recalculateTotals(); } }); }), ])])]);
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onPressed}) => InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(32), child: Container(width: 24, height: 24, decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFFDFDEDE)), borderRadius: BorderRadius.circular(32))), child: Icon(icon, size: 16)));

  Widget _shippingInfo({required int itemCount, required double itemsTotal, required double shipping, required double discount, required double subTotal}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Shipping Information', style: TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)), const SizedBox(height: 16), _buildPriceRow('Total ($itemCount items)', '${itemsTotal.toStringAsFixed(2)} ₹'), const SizedBox(height: 12), _buildPriceRow('Shipping Fee', '${shipping.toStringAsFixed(2)} ₹'), _buildPriceRow('Discount', '-${discount.toStringAsFixed(2)} ₹', valueColor: Colors.green), const SizedBox(height: 12), const Divider(color: Color(0xFFCBCBCB), thickness: 1), const SizedBox(height: 12), _buildPriceRow('Sub Total', '${subTotal.toStringAsFixed(2)} ₹', isBold: true), const Divider(color: Color(0xFFCBCBCB), thickness: 1)]);

  Widget _buildPriceRow(String label, String value, {Color? valueColor, bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: const Color(0xFF292526), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: isBold ? FontWeight.w600 : FontWeight.w400)), Text(value, textAlign: TextAlign.right, style: TextStyle(color: valueColor ?? const Color(0xFF121111), fontSize: isBold ? 16 : 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600))]);

  Widget _contactDetailsSection() { final email = userProfile?.user.email ?? 'Loading...'; final phone = userProfile?.user.phone ?? 'Loading...'; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Contact Details', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600, height: 1.14)), const SizedBox(height: 16), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: ShapeDecoration(color: const Color(0xFFF2F2F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Email', style: TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500, height: 1.71)), const SizedBox(height: 6), Text(email, style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500)), const SizedBox(height: 16), const Text('Phone Number', style: TextStyle(color: Color(0xFFABABAB), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500, height: 1.71)), const SizedBox(height: 6), Text(phone, style: const TextStyle(color: Color(0xFF121111), fontSize: 14, fontFamily: 'Encode Sans', fontWeight: FontWeight.w500))]))]); }

  Widget _addressTile({required Address address, required bool isSelected, required VoidCallback onTap, required VoidCallback onEdit, required VoidCallback onRemove}) => Dismissible(key: Key(address.id), direction: DismissDirection.horizontal, background: Container(decoration: BoxDecoration(color: const Color(0xFFCCF656), borderRadius: BorderRadius.circular(20)), alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.edit, color: Colors.white)), secondaryBackground: Container(decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)), confirmDismiss: (direction) async { if (direction == DismissDirection.startToEnd) { onEdit(); return false; } else { return await showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text("Confirm Delete"), content: const Text("Are you sure you want to remove this address?"), actions: <Widget>[TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")), TextButton(onPressed: () { Navigator.of(context).pop(true); onRemove(); }, child: const Text("DELETE", style: TextStyle(color: Colors.red)))]) ); } }, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(width: isSelected ? 2 : 1, color: isSelected ? const Color(0xFF2C2C2C) : const Color(0xFFD3D3D3)), borderRadius: BorderRadius.circular(20))), child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 65, height: 66, decoration: ShapeDecoration(color: const Color(0xFFF2F2F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Icon(address.icon, size: 30, color: Colors.black54)), const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(address.label, style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('${address.fullAddress}, ${address.phone}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF8D8D8D), fontSize: 12, fontFamily: 'Encode Sans', fontWeight: FontWeight.w400))])), const SizedBox(width: 8), _customRadioButton(isSelected)]))));

  Widget _customRadioButton(bool isSelected) => Container(width: 18, height: 18, decoration: ShapeDecoration(shape: OvalBorder(side: BorderSide(width: isSelected ? 2 : 1, color: isSelected ? const Color(0xFF2C2C2C) : const Color(0xFFD3D3D3)))), child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const ShapeDecoration(color: Color(0xFF2C2C2C), shape: OvalBorder()))) : null);

  Widget _addNewButton(String text, VoidCallback onTap) => OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.add, color: Colors.black), label: Text(text, style: const TextStyle(color: Colors.black)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFDAFF00)), minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFFDAFF00).withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Widget _buildPaymentSection() {
    if (_selectedPaymentMethod != null) {
      String title = 'Unknown Payment Method'; IconData icon = Icons.credit_card; Color iconColor = Colors.grey;
      if (_selectedPaymentMethod is CardModel) { final card = _selectedPaymentMethod as CardModel; title = '${card.brand} **** ${card.last4}'; icon = Icons.credit_card; iconColor = Colors.blue; } else if (_selectedPaymentMethod is UpiModel) { final upi = _selectedPaymentMethod as UpiModel; title = upi.upiId; icon = Icons.account_balance_wallet; iconColor = Colors.green; } else if (_selectedPaymentMethod is WalletModel) { final wallet = _selectedPaymentMethod as WalletModel; title = wallet.name; icon = Icons.account_balance_wallet; iconColor = Colors.orange; }
      return Card(margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 1, child: ListTile(leading: Icon(icon, color: iconColor), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: TextButton(onPressed: _selectPaymentMethod, child: const Text("Change", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))));
    } else { return _addNewButton("Choose Payment Method", _selectPaymentMethod); }
  }
}
