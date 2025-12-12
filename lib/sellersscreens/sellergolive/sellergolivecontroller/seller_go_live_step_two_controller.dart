import 'package:get/get.dart';
import 'package:zatch_app/model/product_response_seller.dart';

// class SellerGoLiveStepTwoController extends GetxController {
//   final RxMap<String, BargainSetting> bargainSettings =
//       <String, BargainSetting>{}.obs;
//   final RxList<ProductItem> zatchFilteredProducts = <ProductItem>[].obs;
//   late RxList<ProductItem> allProducts;

//   void initProducts(RxList<ProductItem> products) {
//     allProducts = products;
//     zatchFilteredProducts.assignAll(products);

//     for (final p in products) {
//       bargainSettings[p.id] = BargainSetting(
//         isEnabled: true,
//         autoAccept: 5,
//         maxDiscount: 30,
//       );
//     }
//   }

//   void updateBargain({
//     required String productId,
//     bool? enabled,
//     double? autoAccept,
//     double? maxDiscount,
//   }) {
//     final setting = bargainSettings[productId];
//     if (setting == null) return;

//     bargainSettings[productId] = setting.copyWith(
//       isEnabled: enabled,
//       autoAccept: autoAccept,
//       maxDiscount: maxDiscount,
//     );
//   }
// }

class BargainSetting {
  final bool isEnabled;
  final double autoAccept;
  final double maxDiscount;

  BargainSetting({
    required this.isEnabled,
    required this.autoAccept,
    required this.maxDiscount,
  });

  BargainSetting copyWith({
    bool? isEnabled,
    double? autoAccept,
    double? maxDiscount,
  }) {
    return BargainSetting(
      isEnabled: isEnabled ?? this.isEnabled,
      autoAccept: autoAccept ?? this.autoAccept,
      maxDiscount: maxDiscount ?? this.maxDiscount,
    );
  }
}
