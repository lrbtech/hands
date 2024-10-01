import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/base_response_model.dart';
import 'package:hands_user_app/model/booking_detail_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/screens/booking/component/price_common_widget.dart';
import 'package:hands_user_app/screens/payment/component/coupon_model.dart';
import 'package:hands_user_app/screens/wallet/user_wallet_balance_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/extensions/num_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';

import '../../component/app_common_dialog.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/wallet_balance_component.dart';
import '../../model/configuration_response.dart';
import '../../network/rest_apis.dart';
import '../../services/airtel_money/airtel_money_service.dart';
import '../../services/cinet_pay_services_new.dart';
import '../../services/flutter_wave_service_new.dart';
import '../../services/midtrans_service.dart';
import '../../services/paypal_service.dart';
import '../../services/paystack_service.dart';
import '../../services/phone_pe/phone_pe_service.dart';
import '../../services/razorpay_service_new.dart';
import '../../services/sadad_services_new.dart';
import '../../services/stripe_service_new.dart';
import '../../utils/configs.dart';
import '../../utils/model_keys.dart';
import '../dashboard/dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingDetailResponse bookings;
  final bool isForAdvancePayment;

  PaymentScreen({required this.bookings, this.isForAdvancePayment = false});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentPaymentMethod;

  num totalAmount = 0;
  num? advancePaymentAmount;

  final TextEditingController couponController = TextEditingController();
  CouponModel? coupun;

  @override
  void initState() {
    super.initState();
    couponController.text = widget.bookings.couponData?.code ?? '';
    init();
  }

  void init() async {
    ///Set app configurations
    getAppConfigurations();

    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    if (widget.bookings.service!.isAdvancePayment) {
      paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);
    }

    currentPaymentMethod = paymentList.first;

    if (widget.bookings.service!.isAdvancePayment &&
        widget.bookings.bookingDetail!.bookingPackage == null) {
      if (widget.bookings.bookingDetail!.paidAmount.validate() == 0) {
        advancePaymentAmount =
            widget.bookings.bookingDetail!.totalAmount.validate() *
                widget.bookings.service!.advancePaymentPercentage.validate() /
                100;
        totalAmount = widget.bookings.bookingDetail!.totalAmount.validate() *
            widget.bookings.service!.advancePaymentPercentage.validate() /
            100;
      } else {
        totalAmount = widget.bookings.bookingDetail!.totalAmount.validate() -
            widget.bookings.bookingDetail!.paidAmount.validate();
      }
    } else {
      totalAmount = widget.bookings.bookingDetail!.totalAmount.validate();
    }
    if (appStore.isEnableUserWallet) {
      paymentList.add(PaymentSetting(
          title: language.wallet, type: PAYMENT_METHOD_FROM_WALLET, status: 1));
    }

    log(totalAmount);

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _handleClick() async {
    if (currentPaymentMethod!.type == PAYMENT_METHOD_COD) {
      savePay(
        paymentMethod: PAYMENT_METHOD_COD,
        paymentStatus: SERVICE_PAYMENT_STATUS_PENDING,
        id: widget.bookings.couponData?.id,
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_STRIPE) {
      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: widget.bookings.couponData != null
            ? (totalAmount -
                (getCouponPrice(
                  coupon: widget.bookings.couponData!,
                  price: widget.bookings.bookingDetail!.amount!,
                )))
            : totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_STRIPE,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
            id: widget.bookings.couponData?.id,
          );
        },
      );

      stripeServiceNew.stripePay();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_RAZOR) {
      // RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
      //   paymentSetting: currentPaymentMethod!,
      //   totalAmount: totalAmount,
      //   onComplete: (p0) {
      //     savePay(
      //       paymentMethod: PAYMENT_METHOD_RAZOR,
      //       paymentStatus: widget.isForAdvancePayment ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : SERVICE_PAYMENT_STATUS_PAID,
      //       txnId: p0['paymentId'],
      //     );
      //   },
      // );
      // razorPayServiceNew.razorPayCheckout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

      flutterWaveServiceNew.checkout(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
            id: widget.bookings.couponData?.id,
          );
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        toast(language.cinetPayNotSupportedMessage);
        return;
      } else if (totalAmount < 100) {
        return toast(
            '${language.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (totalAmount > 1500000) {
        return toast(
            '${language.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_CINETPAY,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
            id: widget.bookings.couponData?.id,
          );
        },
      );

      cinetPayServices.payWithCinetPay(context: context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        remarks: language.topUpWallet,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_SADAD_PAYMENT,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
            id: widget.bookings.couponData?.id,
          );
        },
      );

      sadadServices.payWithSadad(context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PAYPAL) {
      PayPalService.paypalCheckOut(
        context: context,
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          log('PayPalService onComplete: $p0');
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYPAL,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
            id: widget.bookings.couponData?.id,
          );
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
              amount: totalAmount,
              reference: APP_NAME,
              paymentSetting: currentPaymentMethod!,
              bookingId: widget.bookings.bookingDetail != null
                  ? widget.bookings.bookingDetail!.id.validate()
                  : 0,
              onComplete: (res) {
                log('RES: $res');
                savePay(
                  paymentMethod: PAYMENT_METHOD_AIRTEL,
                  paymentStatus: widget.isForAdvancePayment
                      ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                      : SERVICE_PAYMENT_STATUS_PAID,
                  txnId: res['transaction_id'],
                  id: widget.bookings.couponData?.id,
                );
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
        totalAmount: totalAmount.toDouble(),
        bookingId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.id.validate()
            : 0,
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYSTACK,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
            id: widget.bookings.couponData?.id,
          );
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
        totalAmount: totalAmount,
        serviceId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.serviceId.validate()
            : 0,
        serviceName: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.serviceName.validate()
            : '',
        servicePrice: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.amount.validate()
            : 0,
        loaderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_MIDTRANS,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"], //TODO: check
            id: widget.bookings.couponData?.id,
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      midtransService.midtransPaymentCheckout();
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount.toDouble(),
        bookingId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.id.validate()
            : 0,
        onComplete: (res) {
          log('RES: $res');
          savePay(
            paymentMethod: PAYMENT_METHOD_PHONEPE,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
            id: widget.bookings.couponData?.id,
          );
        },
      );

      peServices.phonePeCheckout(context);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FROM_WALLET) {
      savePay(
        paymentMethod: PAYMENT_METHOD_FROM_WALLET,
        paymentStatus: widget.isForAdvancePayment
            ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
            : SERVICE_PAYMENT_STATUS_PAID,
        txnId: '',
        id: widget.bookings.couponData?.id,
      );
    }
  }

  void savePay({
    String txnId = '',
    String paymentMethod = '',
    String paymentStatus = '',
    required int? id,
  }) async {
    Map request = {
      CommonKeys.bookingId: widget.bookings.bookingDetail!.id.validate(),
      CommonKeys.customerId: appStore.userId,
      CouponKeys.discount: widget.bookings.service!.discount,
      BookingServiceKeys.totalAmount: totalAmount,
      CommonKeys.dateTime:
          DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now()),
      CommonKeys.txnId: txnId != ''
          ? txnId
          : "#${widget.bookings.bookingDetail!.id.validate()}",
      CommonKeys.paymentStatus: paymentStatus,
      CommonKeys.paymentMethod: paymentMethod,
      CommonKeys.couponId: id,
    };

    if (widget.bookings.service != null &&
        widget.bookings.service!.isAdvancePayment) {
      request[AdvancePaymentKey.advancePaymentAmount] =
          advancePaymentAmount ?? widget.bookings.bookingDetail!.paidAmount;

      if ((widget.bookings.bookingDetail!.paymentStatus == null ||
              widget.bookings.bookingDetail!.paymentStatus !=
                  SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
              widget.bookings.bookingDetail!.paymentStatus !=
                  SERVICE_PAYMENT_STATUS_PAID) &&
          (widget.bookings.bookingDetail!.paidAmount == null ||
              widget.bookings.bookingDetail!.paidAmount.validate() <= 0)) {
        request[CommonKeys.paymentStatus] = SERVICE_PAYMENT_STATUS_ADVANCE_PAID;
      } else if (widget.bookings.bookingDetail!.paymentStatus ==
          SERVICE_PAYMENT_STATUS_ADVANCE_PAID) {
        request[CommonKeys.paymentStatus] = SERVICE_PAYMENT_STATUS_PAID;
      }
    }

    appStore.setLoading(true);
    savePayment(request).then((value) {
      appStore.setLoading(false);
      push(DashboardScreen(redirectToBooking: true),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.payment,
        color: context.primaryColor,
        textColor: Colors.white,
        backWidget: BackWidget(),
        textSize: APP_BAR_TEXT_SIZE,
      ),
      body: GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: Stack(
          children: [
            AnimatedScrollView(
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceCommonWidget(
                          bookingDetail: widget.bookings.bookingDetail!,
                          serviceDetail: widget.bookings.service!,
                          taxes:
                              widget.bookings.bookingDetail!.taxes.validate(),
                          couponData: widget.bookings.couponData,
                          bookingPackage: widget
                                      .bookings.bookingDetail!.bookingPackage !=
                                  null
                              ? widget.bookings.bookingDetail!.bookingPackage
                              : null,
                        ),
                        32.height,
                        Text(
                          language.lblCoupon,
                          style: boldTextStyle(size: LABEL_TEXT_SIZE),
                        ),
                        16.height,
                        Container(
                          // margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            // color: lightGrey.withOpacity(0.2),
                            border: Border.all(color: lightGrey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              AppTextField(
                                enabled: widget.bookings.couponData == null,
                                textFieldType: TextFieldType.NAME,
                                controller: couponController,
                                textStyle: primaryTextStyle().copyWith(
                                  color: appStore.isDarkMode ? white : black,
                                ),
                                decoration: InputDecoration(
                                  hintText: language.applyCoupon,
                                  hintStyle: primaryTextStyle().copyWith(
                                    color: dimGray,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ).expand(),
                              widget.bookings.couponData == null
                                  ? GestureDetector(
                                      onTap: () async {
                                        hideKeyboard(context);
                                        if (couponController.text.isNotEmpty) {
                                          Either<CouponBaseModel, CouponModel>
                                              result = await applyCoupn(
                                            coupon: couponController.text,
                                            bookingId: widget
                                                .bookings.bookingDetail!.id!,
                                          );

                                          result.fold(
                                            (error) {
                                              // print('There is an error here...');
                                              toast(appStore.isArabic
                                                  ? error.messageAr!
                                                  : error.message!);
                                            },
                                            (success) {
                                              toast(appStore.isArabic
                                                  ? 'تم تطبيق القسيمة بنجاح'
                                                  : 'Coupn has been applied successfully');
                                              print(
                                                  'Everything is success... ${success.toJson()}');

                                              widget.bookings.couponData =
                                                  CouponData.fromJson(
                                                      success.toJson());

                                              // coupun = CouponModel.fromJson(success.toJson());

                                              // widget.bookings.bookingDetail!.amount = 0;

                                              setState(() {});
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 120,
                                        padding: EdgeInsets.all(12),
                                        // margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: appStore.isDarkMode
                                              ? lightGray
                                              : context.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            language.lblApply,
                                            style: primaryTextStyle().copyWith(
                                                color: appStore.isDarkMode
                                                    ? context.primaryColor
                                                    : white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        //
                                        widget.bookings.couponData = null;
                                        setState(() {});
                                      },
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: appStore.isDarkMode
                                            ? lightGray
                                            : context.primaryColor,
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: appStore.isDarkMode
                                              ? context.primaryColor
                                              : white,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        32.height,
                        Text(language.lblChoosePaymentMethod,
                            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      ],
                    ).paddingAll(16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        // color: lightGrey.withOpacity(0.2),
                        border: Border.all(color: lightGrey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/card_pay.png',
                                    width: 21,
                                    color: appStore.isDarkMode ? white : black,
                                  ),
                                  10.width,
                                  Image.asset(
                                    'assets/icons/google_pay.png',
                                    width: 20,
                                    color: appStore.isDarkMode ? white : black,
                                  ),
                                  13.width,
                                  Image.asset(
                                    'assets/icons/apple_pay.png',
                                    width: 20,
                                    color: appStore.isDarkMode ? white : black,
                                  ),
                                ],
                              ),
                              10.width,
                              Text(
                                language.paymentTitle,
                                style: primaryTextStyle(size: 12),
                              ).expand(),
                            ],
                          ).expand(),
                          Checkbox(
                            value: true,
                            activeColor: primaryColor,
                            onChanged: (x) {},
                          ),
                        ],
                      ),
                    ),
                    // if (paymentList.isNotEmpty)
                    //   AnimatedListView(
                    //     itemCount: paymentList.length,
                    //     shrinkWrap: true,
                    //     physics: NeverScrollableScrollPhysics(),
                    //     listAnimationType: ListAnimationType.FadeIn,
                    //     fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                    //     itemBuilder: (context, index) {
                    //       PaymentSetting value = paymentList[index];

                    //       if (value.status.validate() == 0) return Offstage();

                    //       return Container(
                    //         padding: const EdgeInsets.symmetric(horizontal: 16),
                    //         margin: const EdgeInsets.symmetric(horizontal: 16),
                    //         decoration: BoxDecoration(
                    //           // color: lightGrey.withOpacity(0.2),
                    //           border: Border.all(color: lightGrey),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: CheckboxListTile(
                    //           contentPadding: EdgeInsets.zero,
                    //           side: BorderSide(color: redColor),
                    //           dense: true,
                    //           activeColor: primaryColor,
                    //           value: true,
                    //           controlAffinity: ListTileControlAffinity.trailing,
                    //           onChanged: null,
                    //           // groupValue: currentPaymentMethod,
                    //           // onChanged: (ind) {
                    //           //   // currentPaymentMethod = ind;

                    //           //   // setState(() {});
                    //           // },
                    //           title: Text(language.paymentTitle, style: primaryTextStyle()),
                    //         ),
                    //       );

                    //       // return RadioListTile<PaymentSetting>(
                    //       //   // fillColor: MaterialStateProperty.all(greenColor),
                    //       //   dense: true,
                    //       //   // tileColor: context.cardColor,
                    //       //   activeColor: primaryColor,
                    //       //   value: value,
                    //       //   controlAffinity: ListTileControlAffinity.trailing,
                    //       //   groupValue: currentPaymentMethod,
                    //       //   onChanged: (PaymentSetting? ind) {
                    //       //     currentPaymentMethod = ind;

                    //       //     setState(() {});
                    //       //   },
                    //       //   title: Text(value.title.validate(), style: primaryTextStyle()),
                    //       // );
                    //     },
                    //   )
                    // else
                    //   NoDataWidget(
                    //     title: language.noPaymentMethodFound,
                    //     imageWidget: EmptyStateWidget(),
                    //   ),
                    Observer(builder: (context) {
                      return WalletBalanceComponent()
                          .paddingSymmetric(vertical: 8, horizontal: 16)
                          .visible(appStore.isEnableUserWallet);
                    }),
                    if (paymentList.isNotEmpty)
                      AppButton(
                        onTap: () async {
                          if (currentPaymentMethod!.type ==
                                  PAYMENT_METHOD_COD ||
                              currentPaymentMethod!.type ==
                                  PAYMENT_METHOD_FROM_WALLET) {
                            if (currentPaymentMethod!.type ==
                                PAYMENT_METHOD_FROM_WALLET) {
                              appStore.setLoading(true);
                              num walletBalance = await getUserWalletBalance();

                              appStore.setLoading(false);
                              if (walletBalance >= totalAmount) {
                                showCustomConfirmDialog(
                                  context,
                                  dialogType: DialogType.CONFIRMATION,
                                  title:
                                      "${language.lblPayWith} ${currentPaymentMethod!.title.validate()}?",
                                  primaryColor: primaryColor,
                                  positiveText: language.lblYes,
                                  negativeText: language.lblCancel,
                                  onAccept: (p0) {
                                    _handleClick();
                                  },
                                );
                              } else {
                                toast(language.insufficientBalanceMessage);

                                showCustomConfirmDialog(
                                  context,
                                  dialogType: DialogType.CONFIRMATION,
                                  title: language.doYouWantToTopUpYourWallet,
                                  positiveText: language.lblYes,
                                  negativeText: language.lblNo,
                                  cancelable: false,
                                  primaryColor: context.primaryColor,
                                  onAccept: (p0) {
                                    pop();
                                    push(UserWalletBalanceScreen());
                                  },
                                  onCancel: (p0) {
                                    pop();
                                  },
                                );
                              }
                            } else {
                              showCustomConfirmDialog(
                                context,
                                dialogType: DialogType.CONFIRMATION,
                                title:
                                    "${language.lblPayWith} ${currentPaymentMethod!.title.validate()}?",
                                primaryColor: primaryColor,
                                positiveText: language.lblYes,
                                negativeText: language.lblCancel,
                                onAccept: (p0) {
                                  _handleClick();
                                },
                              );
                            }
                          } else {
                            _handleClick();
                          }
                        },
                        text: widget.bookings.couponData != null
                            ? "${language.lblPayNow} ${(totalAmount - (getCouponPrice(
                                  coupon: widget.bookings.couponData!,
                                  price: widget.bookings.bookingDetail!.amount!,
                                ))).toPriceFormat()}"
                            : "${language.lblPayNow} ${totalAmount.toPriceFormat()}",
                        color: context.primaryColor,
                        width: context.width(),
                      ).paddingAll(16),
                  ],
                ),
              ],
            ),
            Observer(
                builder: (context) =>
                    LoaderWidget().visible(appStore.isLoading)).center()
          ],
        ),
      ),
    );
  }
}
