import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zatch_app/common_widgets/appcolors.dart';
import 'package:zatch_app/common_widgets/appsizedbox.dart';
import 'package:zatch_app/model/product_response_seller.dart';
import 'package:zatch_app/sellersscreens/sellergolive/sellergolivecontroller/sellergolivecontroller.dart';

class Golivescreen extends StatefulWidget {
  const Golivescreen({super.key});

  @override
  State<Golivescreen> createState() => _GolivescreenState();
}

class _GolivescreenState extends State<Golivescreen> {
  final Sellergolivecontroller yourlivesscreenscontroller =
      Get.put<Sellergolivecontroller>(Sellergolivecontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: AppBar(
            backgroundColor: const Color(0xffd5ff4d),
            automaticallyImplyLeading: false,
            elevation: 0,
            title: const Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.contentColorWhite,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.contentColorBlack,
                      size: 16,
                    ),
                  ),
                  Text(
                    'Go live',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 15.18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.notifications_none,
                    size: 28,
                    color: AppColors.contentColorBlack,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 24.0,
                    ),
                    child: GoliveuploadStepper(
                      currentStep: yourlivesscreenscontroller.currentStep.value,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Obx(() {
                            if (yourlivesscreenscontroller.currentStep.value ==
                                0) {
                              return GoLiveStepOne();
                            } else if (yourlivesscreenscontroller
                                    .currentStep
                                    .value ==
                                1) {
                              return GoLiveStepTwo(
                                product:
                                    yourlivesscreenscontroller.selectedProducts,
                              );
                            } else {
                              return GoliveStepsthree();
                            }
                          }),
                        ),
                        AppSizedBox.height100,
                        AppSizedBox.height100,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        right: 30,
                        left: 30,
                        top: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Obx(() {
                            final count =
                                yourlivesscreenscontroller
                                    .selectedProducts
                                    .length;
                            final step =
                                yourlivesscreenscontroller.currentStep.value;
                            return (count == 0 || step > 1)
                                ? const SizedBox.shrink() // hide the widget
                                : Text(
                                  '$count Item${count > 1 ? 's' : ''} Selected',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                yourlivesscreenscontroller.onBackPressed(
                                  context,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child:
                                  yourlivesscreenscontroller
                                              .currentStep
                                              .value ==
                                          0
                                      ? const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                      : const Text(
                                        'Back',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      right: 30,
                      left: 30,
                      bottom: 30,
                      top: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      // onPressed: () async {
                      //   //continue
                      //   yourlivesscreenscontroller.nextStep();
                      //   log(
                      //     yourlivesscreenscontroller.currentStep.value
                      //         .toString(),
                      //   );
                      //   // 2. Call Step One API
                      //   yourlivesscreenscontroller.goliveAddProductStep();

                      //   yourlivesscreenscontroller.currentStep.value == 2
                      //       ? Navigator.of(context).pushAndRemoveUntil(
                      //         MaterialPageRoute(
                      //           builder:
                      //               (context) =>
                      //                   const GoliveAddedSuccessScreen(),
                      //         ),
                      //         (Route<dynamic> route) => false,
                      //       )
                      //       : const SizedBox();
                      // },
                      onPressed: () async {
                        try {
                          // Call both steps in one function
                          await yourlivesscreenscontroller.goLiveSteps(context);
                          // yourlivesscreenscontroller.nextStep();
                          log(
                            yourlivesscreenscontroller.currentStep.value
                                .toString(),
                          );
                          // Navigate only if Step 2 is complete
                          if (yourlivesscreenscontroller.currentStep.value ==
                              2) {
                            // if (!yourlivesscreenscontroller.validateStep3())
                            //   return;
                            // yourlivesscreenscontroller.clearGoLiveData();
                          }
                        } catch (e) {
                          log("Error in goLive button: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(163, 221, 0, 1),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoliveuploadStepper extends StatelessWidget {
  final int currentStep;
  const GoliveuploadStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = ['Add\nProduct', 'Zatches', 'Live\nDetails'];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool isActive = currentStep >= index;
            final bool isCompleted = currentStep > index;
            // The line connecting the circles
            final Widget line = Expanded(
              child: Container(
                height: 2,
                color:
                    isCompleted
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFDDDDDD),
              ),
            );
            final Widget circle = Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? const Color(0xFFA2DC00)
                        : const Color(0xFFDDDDDD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? const Color(0xFFA2DC00)
                                    : const Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        ),
              ),
            );
            if (index > 0) {
              return Expanded(child: Row(children: [line, circle]));
            }
            return circle;
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Text(
              steps[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF2C2C2C),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight:
                    currentStep == index ? FontWeight.w600 : FontWeight.w400,
                height: 1.36,
                wordSpacing: 1.6,
              ),
            );
          }),
        ),
      ],
    );
  }
}

final Sellergolivecontroller yourlivesscreenscontroller =
    Get.put<Sellergolivecontroller>(Sellergolivecontroller());

class GoLiveStepOne extends StatefulWidget {
  GoLiveStepOne({super.key});

  @override
  State<GoLiveStepOne> createState() => _GoLiveStepOneState();
}

class _GoLiveStepOneState extends State<GoLiveStepOne> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Products',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.add),
                  Text(
                    'Add New Products',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 15.18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSizedBox.height8,
          const Text(
            "Offer Name",
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.36,
              wordSpacing: 1.6,
            ),
          ),
          AppSizedBox.height10,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF626262)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: yourlivesscreenscontroller.searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search by product name or category',
                      hintStyle: TextStyle(
                        color: Color(0xFF626262),
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSizedBox.height10,
          SingleChildScrollView(child: _golivebody(context)),
        ],
      ),
    );
  }

  Widget? _golivebody(BuildContext context) {
    return Obx(() {
      if (yourlivesscreenscontroller.filteredProducts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 40, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "No matching products found",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: yourlivesscreenscontroller.filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = yourlivesscreenscontroller.filteredProducts[index];
              return _goliveproducttile(p);
            },
          ),
        ],
      );
    });
  }

  Widget _goliveproducttile(ProductItem p) {
    final isSelected = yourlivesscreenscontroller.selectedProducts.any(
      (prod) => prod.id == p.id,
    );
    final isActive = yourlivesscreenscontroller.isProductActive(p.id);

    Widget productTileContentGolive = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            (isSelected && isActive)
                ? const Color(0xFFFAFDF2)
                : const Color(0xFFF8FAFB),

        borderRadius: BorderRadius.circular(12.75),
        border: Border.all(
          color:
              (isSelected && isActive)
                  ? const Color(0xFFA2DC00)
                  : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 4),
            decoration: ShapeDecoration(
              color:
                  isSelected && isActive
                      ? const Color(0xFFA2DC00)
                      : const Color(0xFFF2F4F6),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color:
                      isSelected && isActive
                          ? const Color(0xFFA2DC00)
                          : Colors.black.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:
                isSelected && isActive
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
          ),

          const SizedBox(width: 12),

          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(25),

            // child: Image.asset("assets/images/image_95.png", width: 70),
            child: Image.network(
              p.images.isNotEmpty ? p.images.first.url : '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/image_95.png",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.30,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF101727),
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Flexible(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(0.4),
                          1: FlexColumnWidth(0.4),
                          2: FlexColumnWidth(0.9),
                        },
                        children: [
                          TableRow(
                            children: [
                              const Text(
                                'Cost',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '${p.discountedPrice}₹',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
                                ),
                              ),
                            ],
                          ),

                          const TableRow(
                            children: [
                              SizedBox(height: 6),
                              SizedBox(height: 6),
                              SizedBox(height: 6),
                            ],
                          ),

                          const TableRow(
                            children: [
                              Text(
                                'SKU',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '32',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
                                ),
                              ),
                            ],
                          ),

                          const TableRow(
                            children: [
                              SizedBox(height: 6),
                              SizedBox(height: 6),
                              SizedBox(height: 6),
                            ],
                          ),

                          const TableRow(
                            children: [
                              Text(
                                'Stock',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '16 Units',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF272727),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1.75,
                              ),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFECD4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.75),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    '23KU Low Stock',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF9F2D00),
                                      fontSize: 8,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSizedBox.height5,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      size: 11,
                                      color: Color(0xFF697282),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '${p.viewCount}',
                                      style: const TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 10,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 11,
                                      color: Color(0xFF697282),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '${p.averageRating}',
                                      style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 10,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          yourlivesscreenscontroller.toggleProductActive(p.id);

          if (isSelected) {
            yourlivesscreenscontroller.selectedProducts.removeWhere(
              (prod) => prod.id == p.id,
            );
          } else {
            yourlivesscreenscontroller.selectedProducts.add(p);
          }
        });
        log("the product id : ${p.id}");
      },
      // child: Stack(
      //   children: [
      //     ColorFiltered(
      //       colorFilter:
      //           !isActive
      //               ? greyscale
      //               : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      //       child: productTileContentGolive,
      //     ),
      //   ],
      // ),
      child: productTileContentGolive,
    );
  }
}

class GoLiveStepTwo extends StatefulWidget {
  final RxList<ProductItem> product;

  GoLiveStepTwo({super.key, required this.product});

  @override
  State<GoLiveStepTwo> createState() => _GoLiveStepTwoState();
}

class _GoLiveStepTwoState extends State<GoLiveStepTwo> {
  final controller = Get.put(Sellergolivecontroller());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zatches Settings',
                style: TextStyle(
                  color: Color(0xFF101727),
                  fontSize: 15.18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSizedBox.height10,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF626262)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: yourlivesscreenscontroller.zatchsearchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search by product name or category',
                      hintStyle: TextStyle(
                        color: Color(0xFF626262),
                        fontSize: 14,
                        fontFamily: 'Encode Sans',
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      yourlivesscreenscontroller.searchZatchProducts(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          AppSizedBox.height10,

          Obx(() {
            final list = yourlivesscreenscontroller.zatchFilteredProducts;

            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No matching products found",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildProductCard(list[index]),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductItem product) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),

                // child: Image.asset("assets/images/image_95.png", width: 70),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first.url : '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/image_95.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizedBox.height5,
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: 'Inter',

                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      AppSizedBox.height5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductDetailRow(
                                label: 'Cost',
                                value: '${product.price}',
                              ),
                              const SizedBox(height: 4),
                              ProductDetailRow(label: 'SKU', value: '12345'),
                              const SizedBox(height: 4),
                              ProductDetailRow(
                                label: 'Stock',
                                value: '10 Units',
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.remove_red_eye,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text('${product.viewCount}'),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.star,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text('${product.averageRating}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 8.0),
                child: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),

          //bargain settings card
          OnbargainSettingscard(product: product),
        ],
      ),
    );
  }

  ProductDetailRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          '$label -',
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: Color(0xFF272727),
          ),
        ),
      ],
    );
  }
}

class OnbargainSettingscard extends StatefulWidget {
  final ProductItem product;
  OnbargainSettingscard({super.key, required this.product});

  @override
  State<OnbargainSettingscard> createState() => _OnbargainSettingscardState();
}

class _OnbargainSettingscardState extends State<OnbargainSettingscard> {
  final controller = Get.find<Sellergolivecontroller>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final setting = controller.bargainSettings[widget.product.id];
      if (setting == null) {
        return const SizedBox();
      }
      final autoAcceptValue =
          widget.product.price * (1 - setting.autoAccept / 100);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.percent, size: 20, color: Color(0xFF101727)),
                  SizedBox(width: 7),
                  Text(
                    'Bargain Settings',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: setting.isEnabled,
                  onChanged:
                      (v) => controller.updateBargain(
                        productId: widget.product.id,
                        enabled: v,
                      ), // handle the switch changes here
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF030213),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),

          if (setting.isEnabled) ...[
            const Row(
              children: [
                Icon(Icons.priority_high, color: Colors.green),
                Flexible(
                  child: Text(
                    "Optional and if added, is applicable to all the products",
                    style: TextStyle(color: Color(0xFF697282), fontSize: 13),
                  ),
                ),
              ],
            ),

            AppSizedBox.height10,
            _buildSlider(
              label: 'Auto-Accept Discount',
              value: setting.autoAccept,
              onChanged:
                  (v) => controller.updateBargain(
                    productId: widget.product.id,
                    autoAccept: v,
                  ),
              displayColor: const Color(0xFF016630),
              backgroundColor: const Color(0xFFECECF0),
              displayValue:
                  '${setting.autoAccept.toInt()}% (₹${autoAcceptValue.toInt()})',
              description:
                  'Orders at this discount or lower will be auto-accepted',
            ),
            AppSizedBox.height10,
            _buildSlider(
              label: 'Maximum Discount',
              value: setting.maxDiscount,
              onChanged:
                  (v) => controller.updateBargain(
                    productId: widget.product.id,
                    maxDiscount: v,
                  ),
              displayColor: const Color(0xFF9F2D00),
              backgroundColor: const Color(0xFFFFECD4),
              displayValue: '${setting.maxDiscount.toInt()}%',
            ),
            AppSizedBox.height10,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 234, 235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Floor:",
                        style: TextStyle(
                          color: Color(0xFF030213),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Buyer will bargain till this price at the most",
                        style: TextStyle(
                          color: Color(0xFF697282),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "₹3000",
                    style: TextStyle(
                      color: Color(0xFF030213),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            AppSizedBox.height10,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: ShapeDecoration(
                    // color:
                    //     isSelected && p.isActive
                    //         ? const Color(0xFFA2DC00)
                    //         : const Color(0xFFF2F4F6),
                    color: const Color(0xFFF2F4F6),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        // color:
                        // isSelected && p.isActive
                        //     ? const Color(0xFFA2DC00)
                        //     : Colors.black.withOpacity(0.1),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // child:
                  //     isSelected && p.isActive
                  //         ? const Icon(
                  //           Icons.check,
                  //           size: 14,
                  //           color: Colors.white,
                  //         )
                  //         : null,
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                AppSizedBox.width10,
                const Text(
                  'Apply this settings to all Products',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color displayColor,
    required Color backgroundColor,
    required String displayValue,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 1.75,
              ),
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.75),
                ),
              ),
              child: Text(
                displayValue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: displayColor,
                  fontSize: 10.50,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 14.0,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: const Color(0xFF030213),
              inactiveTrackColor: const Color(0xFFECECF0),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7.0,
                elevation: 2.0,
              ),
              thumbColor: Colors.white,
              overlayColor: Colors.transparent,
            ),
            child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF697282),
              fontSize: 10.50,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// go live step 3 - golivestepthree
class GoliveStepsthree extends StatefulWidget {
  const GoliveStepsthree({super.key});

  @override
  State<GoliveStepsthree> createState() => _GoliveStepsthreeState();
}

class _GoliveStepsthreeState extends State<GoliveStepsthree> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: yourlivesscreenscontroller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Details',
              style: TextStyle(
                color: Color(0xFF101727),
                fontSize: 15.18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSizedBox.height10,

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: yourlivesscreenscontroller.tabController,

                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade900,
                    tabs: const [
                      Tab(text: "Go Live Now"),
                      Tab(text: "Shedule Live"),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Live Title *',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                AppSizedBox.height10,
                TextFormField(
                  onChanged: (value) {},
                  controller: yourlivesscreenscontroller.titlecontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Enter Title',
                    hintStyle: const TextStyle(
                      color: Color(0xFF717182),
                      fontSize: 12.30,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFA2DC00),
                      ),
                    ),
                  ),
                ),
                AppSizedBox.height10,
                const Text(
                  'Live Description *',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                TextFormField(
                  controller: yourlivesscreenscontroller.descriptioncontroller,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Enter description',
                    hintStyle: const TextStyle(
                      color: Color(0xFF717182),
                      fontSize: 12.30,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4 > 1 ? 16 : 46.75),
                      borderSide: const BorderSide(
                        width: 1,
                        color: Color(0xFFA2DC00),
                      ),
                    ),
                  ),
                ),
                AppSizedBox.height10,
                Obx(() {
                  if (yourlivesscreenscontroller.selectedTab.value == 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date *',
                          style: TextStyle(
                            color: Color(0xFF354152),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                        AppSizedBox.height10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Obx(
                                () => _commonDropdown(
                                  hint: "dd",
                                  items: List.generate(31, (i) => "${i + 1}"),
                                  selectedValue:
                                      yourlivesscreenscontroller
                                          .selectedDay
                                          .value,
                                  onChanged: (v) {
                                    yourlivesscreenscontroller
                                        .selectedDay
                                        .value = v ?? '';
                                  },
                                ),
                              ),
                            ),

                            AppSizedBox.width5,
                            Expanded(
                              child: Obx(
                                () => _commonDropdown(
                                  hint: "mm",
                                  items: List.generate(12, (i) => "${i + 1}"),
                                  selectedValue:
                                      yourlivesscreenscontroller
                                          .selectedMonth
                                          .value,
                                  onChanged: (v) {
                                    yourlivesscreenscontroller
                                        .selectedMonth
                                        .value = v ?? '';
                                  },
                                ),
                              ),
                            ),

                            AppSizedBox.width5,
                            Expanded(
                              child: Obx(
                                () => _commonDropdown(
                                  hint: "yyyy",
                                  items: List.generate(6, (i) => "${2025 + i}"),
                                  selectedValue:
                                      yourlivesscreenscontroller
                                          .selectedYear
                                          .value,
                                  onChanged: (v) {
                                    yourlivesscreenscontroller
                                        .selectedYear
                                        .value = v ?? '';
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Time *',
                          style: TextStyle(
                            color: Color(0xFF354152),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                        AppSizedBox.height10,
                        Row(
                          children: [
                            // Hours
                            Expanded(
                              child: Obx(
                                () => _commonDropdown(
                                  hint: "Hours",
                                  items: List.generate(24, (i) => "${i + 1}"),
                                  selectedValue:
                                      yourlivesscreenscontroller
                                          .selectedHour
                                          .value,
                                  onChanged: (v) {
                                    yourlivesscreenscontroller
                                        .selectedHour
                                        .value = v ?? '';
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Minutes
                            Expanded(
                              child: Obx(
                                () => _commonDropdown(
                                  hint: "Minutes",
                                  items: ["00", "10", "20", "30", "40", "50"],
                                  selectedValue:
                                      yourlivesscreenscontroller
                                          .selectedMinute
                                          .value,
                                  onChanged: (v) {
                                    yourlivesscreenscontroller
                                        .selectedMinute
                                        .value = v ?? '';
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
              ],
            ),

            const Text(
              'Upload Thumbnail Image *',
              style: TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            AppSizedBox.height10,

            GestureDetector(
              onTap: () async {
                bool allowed =
                    await yourlivesscreenscontroller.requestGalleryPermission();
                if (!allowed) {
                  Get.snackbar("Permission", "Gallery permission required");
                  return;
                }

                await yourlivesscreenscontroller.pickImage(ImageSource.gallery);
                if (yourlivesscreenscontroller.tempSelectedImage.value ==
                    null) {
                  Get.snackbar("Error", "Thumbnail Image is required");
                  return;
                }
              },
              child: Obx(() {
                final image =
                    yourlivesscreenscontroller.tempSelectedImage.value;

                return Stack(
                  children: [
                    DashedBorderContainer(
                      child:
                          image == null
                              ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.picture_in_picture, size: 20),
                                  SizedBox(height: 8),
                                  Text(
                                    "Upload From Gallery",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),

                    if (image != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            yourlivesscreenscontroller.tempSelectedImage.value =
                                null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            AppSizedBox.height10,
            const Text(
              'Choose the Order *',
              style: TextStyle(
                color: Color(0xFF354152),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            AppSizedBox.height10,
            Obx(() {
              final list = yourlivesscreenscontroller.zatchFilteredProducts;

              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "No matching products found",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildLivedetailsProductCard(list[index]),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLivedetailsProductCard(ProductItem product) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
                child: Center(child: Icon(Icons.drag_indicator)),
              ),
              AppSizedBox.width5,

              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first.url : '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/image_95.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF101727),
                          fontSize: 15.18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizedBox.height5,
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: 'Inter',

                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      AppSizedBox.height5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'cost',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF697282),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('-'),
                              const SizedBox(width: 4),
                              Text(
                                product.price.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF101727),
                                ),
                              ),
                            ],
                          ),
                          AppSizedBox.width10,
                          Row(
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                size: 18,
                                color: Color(0xFF697282),
                              ),
                              Text(
                                product.viewCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF697282),
                                ),
                              ),
                              AppSizedBox.width10,
                              const Icon(
                                Icons.star,
                                size: 18,
                                color: Color(0xFF697282),
                              ),
                              Text(
                                product.averageRating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF697282),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 8.0),
                child: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _commonDropdown({
    required String hint,
    required List<String> items,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(38),
      ),
      child: DropdownButton<String>(
        value: selectedValue.isEmpty ? null : selectedValue,
        hint: Center(child: Text(hint)),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 15),
        items:
            items.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Center(child: Text(e)),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// dashed
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final double height;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4;
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.6)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    Path path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Offset.zero & size,
            const Radius.circular(12),
          ),
        );

    Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) => false;
}
