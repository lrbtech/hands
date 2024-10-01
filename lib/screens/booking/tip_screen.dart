import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/model/base_response_model.dart';
import 'package:hands_user_app/services/flutter_wave_service_new.dart';
import 'package:hands_user_app/utils/extensions/num_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/app_common_dialog.dart';
import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../main.dart';
import '../../model/configuration_response.dart';
import '../../network/rest_apis.dart';
import '../../services/airtel_money/airtel_money_service.dart';
import '../../services/cinet_pay_services_new.dart';
import '../../services/midtrans_service.dart';
import '../../services/paypal_service.dart';
import '../../services/paystack_service.dart';
import '../../services/phone_pe/phone_pe_service.dart';
import '../../services/razorpay_service_new.dart';
import '../../services/sadad_services_new.dart';
import '../../services/stripe_service_new.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({Key? key, required this.bookingId, this.afterPayment}) : super(key: key);

  final int bookingId;
  final Function? afterPayment;

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  TextEditingController tipAmountCont = TextEditingController(text: '0');
  FocusNode tipAmountFocus = FocusNode();

  List<int> defaultAmounts = [10, 20];
  List<PaymentSetting> paymentList = [];
  PaymentSetting? currentPaymentMethod;

  @override
  void initState() {
    super.initState();
    appStore.setUserWalletAmount();

    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);

    ///TODO We are disabling razorpay temporarily because razorpay library has issue in wallet payments
    paymentList.removeWhere((element) => element.type != PAYMENT_METHOD_STRIPE);
    if (paymentList.isNotEmpty) {
      currentPaymentMethod = paymentList[0];
    }
  }

  Future<void> _handleClick() async {
    if (currentPaymentMethod == null) {
      return toast(language.pleaseChooseAnyOnePayment);
    } else if (tipAmountCont.text.toDouble() == 0) {
      return toast(language.theAmountShouldBeEntered);
    }

    if (currentPaymentMethod!.type == PAYMENT_METHOD_STRIPE) {
      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        onComplete: (p0) async {
          print("P0");
          print(p0);
          Map req = {"booking_id": widget.bookingId, "tip_amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_STRIPE, "transaction_id": p0['transaction_id']};

          bool? isTiped = await tipProvider(req);
          if (isTiped == true) {
            widget.afterPayment?.call();
            finish(context);
          }
        },
      );

      stripeServiceNew.stripePay();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_RAZOR) {
      // RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
      //   paymentSetting: currentPaymentMethod!,
      //   totalAmount: tipAmountCont.text.toDouble(),
      //   onComplete: (p0) {
      //     log(p0);
      //     Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_RAZOR, "transaction_id": p0['orderId']};

      //     walletTopUp(req);
      //   },
      // );
      // razorPayServiceNew.razorPayCheckout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

      flutterWaveServiceNew.checkout(
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        onComplete: (p0) {
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_FLUTTER_WAVE, "transaction_id": p0['transaction_id']};

          walletTopUp(req);
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        toast(language.cinetPayNotSupportedMessage);
        return;
      } else if (tipAmountCont.text.toDouble() < 100) {
        return toast('${language.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (tipAmountCont.text.toDouble() > 1500000) {
        return toast('${language.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        onComplete: (p0) {
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_CINETPAY, "transaction_id": p0['transaction_id']};

          walletTopUp(req);
        },
      );

      cinetPayServices.payWithCinetPay(context: context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        remarks: language.topUpWallet,
        onComplete: (p0) {
          Map req = {
            "amount": tipAmountCont.text.toDouble(),
            "transaction_type": PAYMENT_METHOD_SADAD_PAYMENT,
            "transaction_id": p0['transaction_id'],
          };

          walletTopUp(req);
        },
      );

      sadadServices.payWithSadad(context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PAYPAL) {
      PayPalService.paypalCheckOut(
        context: context,
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        onComplete: (p0) {
          log('PayPalService onComplete: $p0');
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_PAYPAL, "transaction_id": p0['transaction_id']};
          walletTopUp(req);
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_AIRTEL) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        barrierDismissible: false,
        builder: (context) {
          return AppCommonDialog(
            title: language.airtelMoneyPayment,
            child: AirtelMoneyDialog(
              amount: tipAmountCont.text.toDouble(),
              paymentSetting: currentPaymentMethod!,
              reference: APP_NAME,
              bookingId: appStore.userId.validate().toInt(),
              onComplete: (res) {
                log('RES: $res');
                Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_AIRTEL, "transaction_id": res['transaction_id']};
                walletTopUp(req);
              },
            ),
          );
        },
      ).then((value) => appStore.setLoading(false));
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PAYSTACK) {
      PayStackService paystackServices = PayStackService();
      appStore.setLoading(true);
      await paystackServices.init(
        context: context,
        currentPaymentMethod: currentPaymentMethod!,
        loderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        totalAmount: tipAmountCont.text.toDouble(),
        bookingId: appStore.userId.validate().toInt(),
        onComplete: (res) {
          log('RES: $res');
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_PAYSTACK, "transaction_id": res['transaction_id']};
          walletTopUp(req);
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      paystackServices.checkout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_MIDTRANS) {
      //TODO: all params check
      MidtransService midtransService = MidtransService();
      appStore.setLoading(true);
      await midtransService.initialize(
        currentPaymentMethod: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        loaderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        onComplete: (res) {
          //TODO: check
          log('RES: $res');
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_MIDTRANS, "transaction_id": res['transaction_id']};
          walletTopUp(req);
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      midtransService.midtransPaymentCheckout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        paymentSetting: currentPaymentMethod!,
        totalAmount: tipAmountCont.text.toDouble(),
        onComplete: (res) {
          log('RES: $res');
          Map req = {"amount": tipAmountCont.text.toDouble(), "transaction_type": PAYMENT_METHOD_PHONEPE, "transaction_id": res['transaction_id']};
          walletTopUp(req);
        },
      );

      peServices.phonePeCheckout(context);
    }
  }

  String getPaymentMethodIcon(String value) {
    if (value == PAYMENT_METHOD_STRIPE) {
      return stripe_logo;
    } else if (value == PAYMENT_METHOD_RAZOR) {
      return razorpay_logo;
    } else if (value == PAYMENT_METHOD_CINETPAY) {
      return cinetpay_logo;
    } else if (value == PAYMENT_METHOD_FLUTTER_WAVE) {
      return flutter_wave_logo;
    } else if (value == PAYMENT_METHOD_SADAD_PAYMENT) {
      return "";
    } else if (value == PAYMENT_METHOD_PAYPAL) {
      return paypal_logo;
    } else if (value == PAYMENT_METHOD_AIRTEL) {
      return airtel_logo;
    } else if (value == PAYMENT_METHOD_PAYSTACK) {
      return paystack_logo;
    } else if (value == PAYMENT_METHOD_PHONEPE) {
      return phonepe_logo;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.addTip,
      child: AnimatedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        listAnimationType: ListAnimationType.None,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  // Text(language.topUpWallet, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  // 8.height,
                  // Text(language.topUpAmountQuestion, style: secondaryTextStyle()),
                  Container(
                    width: context.width(),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationDefault(
                      color: appStore.isDarkMode ? scaffoldColorDark : white,
                      borderRadius: radius(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appStore.isArabic ? 'أضف إكرامية' : 'Add tip to this provider',
                          style: boldTextStyle(size: 18, color: appStore.isDarkMode ? white : context.primaryColor),
                        ),
                        10.height,
                        Row(
                          children: [
                            Container(
                              // width: 145,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: boxDecorationDefault(
                                color: defaultAmounts[0].toString() == tipAmountCont.text ? (appStore.isDarkMode ? white : context.primaryColor) : (appStore.isDarkMode ? primaryColor : white),
                                borderRadius: radius(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.25),
                                    offset: Offset(0, 3),
                                    blurRadius: 4,
                                    spreadRadius: 0.1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (appStore.currencySymbol) + defaultAmounts[0].toString().formatNumberWithComma(),
                                  style: primaryTextStyle(color: defaultAmounts[0].toString() == tipAmountCont.text ? (appStore.isDarkMode ? primaryColor : white) : (appStore.isDarkMode ? white : primaryColor), size: 16),
                                ),
                              ),
                            ).onTap(() {
                              tipAmountCont.text = defaultAmounts[0].toString();
                              setState(() {});
                            }).expand(),

                            10.width,
                            // 2

                            Container(
                              // width: 145,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: boxDecorationDefault(
                                color: defaultAmounts[1].toString() == tipAmountCont.text ? (appStore.isDarkMode ? white : context.primaryColor) : (appStore.isDarkMode ? primaryColor : white),
                                borderRadius: radius(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.25),
                                    offset: Offset(0, 3),
                                    blurRadius: 4,
                                    spreadRadius: 0.1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (appStore.currencySymbol) + defaultAmounts[1].toString().formatNumberWithComma(),
                                  style: primaryTextStyle(color: defaultAmounts[1].toString() == tipAmountCont.text ? (appStore.isDarkMode ? primaryColor : white) : (appStore.isDarkMode ? white : primaryColor), size: 16),
                                ),
                              ),
                            ).onTap(() {
                              tipAmountCont.text = defaultAmounts[1].toString();
                              setState(() {});
                            }).expand(),
                          ],
                        ),
                        // Wrap(
                        //   spacing: 30,
                        //   runSpacing: 12,
                        //   alignment: WrapAlignment.center,
                        //   children: List.generate(defaultAmounts.length, (index) {
                        //     return Container(
                        //       // width: 145,
                        //       padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        //       decoration: boxDecorationDefault(
                        //         color: defaultAmounts[index].toString() == tipAmountCont.text ? (appStore.isDarkMode ? white : context.primaryColor) : (appStore.isDarkMode ? primaryColor : white),
                        //         borderRadius: radius(8),
                        //       ),
                        //       child: Center(
                        //         child: Text(
                        //           (appStore.currencySymbol) + defaultAmounts[index].toString().formatNumberWithComma(),
                        //           style: primaryTextStyle(
                        //               color: appStore.isDarkMode
                        //                   ? white
                        //                   : defaultAmounts[index].toString() == tipAmountCont.text
                        //                       ? (appStore.isDarkMode ? primaryColor : white)
                        //                       : (appStore.isDarkMode ? white : primaryColor),
                        //               size: 16),
                        //         ),
                        //       ),
                        //     ).onTap(() {
                        //       tipAmountCont.text = defaultAmounts[index].toString();
                        //       setState(() {});
                        //     });
                        //   }),
                        // ),

                        24.height,
                        Text(
                          appStore.isArabic ? 'أدخل المبلغ الذي تريد دفعه' : 'Add your custom amount',
                          style: secondaryTextStyle(),
                        ),
                        5.height,
                        Card(
                          margin: EdgeInsets.zero,
                          color: transparentColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadowColor: primaryColor.withOpacity(0.25),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: primaryColor.withOpacity(0.25),
                                //     offset: Offset(0, 3),
                                //     blurRadius: 4,
                                //     spreadRadius: 0.1,
                                //   ),
                                // ],
                              ),
                              child: AppTextField(
                                textFieldType: TextFieldType.NUMBER,
                                controller: tipAmountCont,
                                focus: tipAmountFocus,
                                textStyle: primaryTextStyle(),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onTap: () {
                                  if (tipAmountCont.text == '0') {
                                    tipAmountCont.selection = TextSelection(baseOffset: 0, extentOffset: tipAmountCont.text.length);
                                  }
                                },
                                decoration: InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: appStore.isDarkMode ? primaryColor : white,
                                        filled: true,
                                        prefixStyle: boldTextStyle(),
                                        prefix: Text(
                                          '${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${isCurrencyPositionRight ? appStore.currencySymbol : ''}',
                                        ).paddingSymmetric(horizontal: 14))
                                    .copyWith(),
                                onChanged: (p0) {
                                  //
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Text(language.paymentMethod, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingSymmetric(horizontal: 16),
                  4.height,
                  Text(language.selectYourPaymentMethodToAddBalance, style: secondaryTextStyle()).paddingSymmetric(horizontal: 16),
                  if (paymentList.isNotEmpty) 16.height,
                  if (paymentList.isNotEmpty)
                    AnimatedWrap(
                      itemCount: paymentList.length,
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                      spacing: 8,
                      runSpacing: 18,
                      itemBuilder: (context, index) {
                        PaymentSetting value = paymentList[index];

                        if (value.status.validate() == 0) return Offstage();
                        String icon = getPaymentMethodIcon(value.type.validate());

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                width: context.width(),
                                child: Container(
                                  width: context.width() * 0.249,
                                  height: 60,
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: boxDecorationDefault(
                                    color: appStore.isDarkMode ? context.primaryColor : white,
                                    borderRadius: radius(8),
                                    // border: Border.all(color: primaryColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.25),
                                        offset: Offset(0, 3),
                                        blurRadius: 4,
                                        spreadRadius: 0.1,
                                      ),
                                    ],
                                  ),
                                  //decoration: BoxDecoration(border: Border.all(color: primaryColor)),
                                  alignment: Alignment.center,
                                  child: 1 == 1
                                      ? Row(
                                          children: [
                                            10.width,
                                            Container(
                                              padding: currentPaymentMethod == value ? EdgeInsets.all(2) : EdgeInsets.zero,
                                              decoration: boxDecorationDefault(color: appStore.isDarkMode ? white : context.primaryColor),
                                              child: Icon(Icons.done, size: 16, color: appStore.isDarkMode ? context.primaryColor : white),
                                            ),
                                            20.width,
                                            Text(
                                              'Visa / Master Card',
                                              style: boldTextStyle(color: appStore.isDarkMode ? white : context.primaryColor),
                                            ),
                                            Spacer(),
                                            Image.asset('assets/icons/upi_payment/mastercard.png')
                                          ],
                                        )
                                      : icon.isNotEmpty
                                          ? Image.asset(icon)
                                          : Text(value.type.validate(), style: primaryTextStyle()),
                                ).onTap(() {
                                  currentPaymentMethod = value;

                                  setState(() {});
                                }),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    NoDataWidget(
                      title: language.lblNoPayments,
                      imageWidget: EmptyStateWidget(),
                    ),
                  30.height,
                  AppButton(
                    width: context.width(),
                    height: 16,
                    elevation: 5,
                    color: appStore.isDarkMode ? context.primaryColor : white,
                    text: language.lblPayNow,
                    textStyle: boldTextStyle(color: appStore.isDarkMode ? white : context.primaryColor),
                    onTap: () async {
                      hideKeyboard(context);
                      _handleClick().then((value) {});
                    },
                  ).paddingSymmetric(horizontal: 8),
                ],
              ).paddingSymmetric(horizontal: 10),
            ],
          ),
        ],
      ),
    );
  }
}
