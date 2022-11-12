import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/screens/cart/widget/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final fromNav;
  CartScreen({@required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, isBackButtonExist: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      body: GetBuilder<CartController>(
        builder: (cartController) {
          List<List<AddOns>> _addOnsList = [];
          List<bool> _availableList = [];
          double _itemPrice = 0;
          double _addOns = 0;
          cartController.cartList.forEach((cartModel) {

            List<AddOns> _addOnList = [];
            cartModel.addOnIds.forEach((addOnId) {
              for(AddOns addOns in cartModel.item.addOns) {
                if(addOns.id == addOnId.id) {
                  _addOnList.add(addOns);
                  break;
                }
              }
            });
            _addOnsList.add(_addOnList);

            _availableList.add(DateConverter.isAvailable(cartModel.item.availableTimeStarts, cartModel.item.availableTimeEnds));

            for(int index=0; index<_addOnList.length; index++) {
              _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
            }
            _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
          });
          double _subTotal = _itemPrice + _addOns;

          return cartController.cartList.length > 0 ? Column(
            children: [

              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL), physics: BouncingScrollPhysics(),
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.WEB_MAX_WIDTH,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          // Product
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartController.cartList.length,
                            itemBuilder: (context, index) {
                              return CartItemWidget(cart: cartController.cartList[index], cartIndex: index, addOns: _addOnsList[index], isAvailable: _availableList[index]);
                            },
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                          // Total
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('item_price'.tr, style: robotoRegular),
                            Text(PriceConverter.convertPrice(_itemPrice), style: robotoRegular),
                          ]),
                          SizedBox(height: Get.find<SplashController>().configModel.moduleConfig.module.addOn ? 10 : 0),

                          Get.find<SplashController>().configModel.moduleConfig.module.addOn ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('addons'.tr, style: robotoRegular),
                              Text('(+) ${PriceConverter.convertPrice(_addOns)}', style: robotoRegular),
                            ],
                          ) : SizedBox(),

                          Get.find<SplashController>().configModel.moduleConfig.module.addOn ? Padding(
                            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                            child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                          ) : SizedBox(),

                          Get.find<SplashController>().configModel.moduleConfig.module.addOn ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('subtotal'.tr, style: robotoMedium),
                              Text(PriceConverter.convertPrice(_subTotal), style: robotoMedium),
                            ],
                          ) : SizedBox(),


                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                width: Dimensions.WEB_MAX_WIDTH,
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                child: CustomButton(buttonText: 'proceed_to_checkout'.tr, onPressed: () {
                  if(Get.find<SplashController>().module == null) {
                    showCustomSnackBar('choose_a_store_category_first'.tr);
                  }else if(!cartController.cartList.first.item.scheduleOrder && _availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  } else {
                    Get.find<CouponController>().removeCouponData(false);
                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  }
                }),
              ),

            ],
          ) : NoDataScreen(isCart: true, text: '');
        },
      ),
    );
  }
}
