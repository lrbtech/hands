import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/model/booking_list_model.dart';
import 'package:hands_user_app/model/extra_charges_model.dart';
import 'package:hands_user_app/model/package_data_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingData {
  int? id;
  String? address;
  int? customerId;
  String? customerName;
  int? serviceId;
  int? providerId;
  int? quantity;
  String? type;
  num? discount;
  int? isUrgent;
  String? statusLabel;
  String? description;
  String? providerName;
  String? serviceName;
  String? paymentStatus;
  String? paymentMethod;
  String? date;
  String? durationDiff;
  int? paymentId;
  int? bookingAddressId;
  String? durationDiffHour;
  String? bookingSlot;
  num? totalAmount;
  num? amount;
  num? paidAmount;
  num? tipAmount;
  AddressModel? addressDetails;
  CouponData? couponData;
  List<Handyman>? handyman;
  List<String>? serviceAttachments;
  String? status;
  List<TaxData>? taxes;
  // Category? category;
  String? reason;
  int? totalReview;
  num? totalRating;
  String? startAt;
  String? endAt;
  String? bookingType;
  Category? category;

  List<ExtraChargesModel>? extraCharges;
  BookingPackage? bookingPackage;

  String? txnId;

  num? finalTotalServicePrice;
  num? finalTotalTax;
  num? finalSubTotal;
  num? finalDiscountAmount;
  num? finalCouponDiscountAmount;

  //Local
  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isFixedService => type.validate() == SERVICE_TYPE_FIXED;

  bool get isSlotBooking => bookingSlot != null;

  bool get isPaid => (paymentId != null && paymentStatus == 'paid');

  bool get isProviderAndHandymanSame => handyman.validate().isNotEmpty ? handyman.validate().first.handymanId.validate() == providerId.validate() : false;

  bool get isFreeService => type.validate() == SERVICE_TYPE_FREE;

  bool get isPostJob => bookingType == BOOKING_TYPE_USER_POST_JOB;

  bool get isPackageBooking => bookingPackage != null;

  bool get canCustomerContact => status != BookingStatusKeys.pending && status != BookingStatusKeys.cancelled && status != BookingStatusKeys.failed && status != BookingStatusKeys.rejected && status != BookingStatusKeys.waitingAdvancedPayment && paymentId != null;

  bool get isAdvancePaymentDone => paidAmount.validate() != 0;

  num get totalExtraChargeAmount => extraCharges.validate().sumByDouble((e) => e.total.validate());

  List<Serviceaddon>? serviceaddon;

  BookingData(
      {this.address,
      this.bookingAddressId,
      this.couponData,
      this.amount,
      this.customerId,
      this.customerName,
      this.date,
      this.description,
      this.discount,
      this.durationDiff,
      this.bookingSlot,
      this.durationDiffHour,
      this.handyman,
      this.id,
      this.paymentId,
      this.category,
      this.isUrgent,
      this.paymentMethod,
      this.paymentStatus,
      this.providerId,
      this.providerName,
      this.quantity,
      this.serviceAttachments,
      this.serviceId,
      this.serviceName,
      this.status,
      this.statusLabel,
      this.taxes,
      this.totalAmount,
      this.type,
      this.reason,
      this.totalReview,
      this.totalRating,
      this.startAt,
      this.endAt,
      this.extraCharges,
      this.bookingType,
      this.bookingPackage,
      this.paidAmount,
      this.finalTotalServicePrice,
      this.finalTotalTax,
      this.finalSubTotal,
      this.finalDiscountAmount,
      this.finalCouponDiscountAmount,
      this.txnId,
      this.serviceaddon,
      this.tipAmount,
      this.addressDetails});

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      address: json['address'],
      bookingSlot: json['booking_slot'],
      isUrgent: json['is_urgent'],
      // bookingSlot: json['timeslot_id'],
      amount: json['amount'],
      totalAmount: json['total_amount'],
      bookingAddressId: json['booking_address_id'],
      couponData: json['coupon_data'] != null ? CouponData.fromJson(json['coupon_data']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      date: json['date'],
      description: json['description'],
      discount: json['discount'],
      durationDiff: json['duration_diff'],
      durationDiffHour: json['duration_diff_hour'],
      handyman: json['handyman'] != null ? (json['handyman'] as List).map((i) => Handyman.fromJson(i)).toList() : null,
      id: json['id'],
      paymentId: json['payment_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      providerId: json['provider_id'],
      providerName: json['provider_name'],
      quantity: json['quantity'],
      serviceAttachments: json['service_attchments'] != null ? new List<String>.from(json['service_attchments']) : null,
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      status: json['status'],
      statusLabel: json['status_label'],
      taxes: json['taxes'] != null ? (json['taxes'] as List).map((i) => TaxData.fromJson(i)).toList() : null,
      type: json['type'],
      reason: json['reason'],
      totalReview: json['total_review'],
      totalRating: json['total_rating'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      extraCharges: json['extra_charges'] != null ? (json['extra_charges'] as List).map((i) => ExtraChargesModel.fromJson(i)).toList() : null,
      bookingType: json['booking_type'],
      bookingPackage: json['booking_package'] != null ? BookingPackage.fromJson(json['booking_package']) : null,
      paidAmount: json[AdvancePaymentKey.advancePaidAmount],
      finalTotalServicePrice: json['final_total_service_price'],
      finalTotalTax: json['final_total_tax'],
      finalSubTotal: json['final_sub_total'],
      finalDiscountAmount: json['final_discount_amount'],
      finalCouponDiscountAmount: json['final_coupon_discount_amount'],
      txnId: json['txn_id'],
      tipAmount: json['tip_amount'],
      addressDetails: json['address_details'] != null ? AddressModel.fromJson(json['address_details']) : null,
      serviceaddon: json['BookingAddonService'] != null ? (json['BookingAddonService'] as List).map((i) => Serviceaddon.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['is_urgent'] = isUrgent;
    data['booking_address_id'] = this.bookingAddressId;
    data['customer_id'] = this.customerId;
    data['customer_name'] = this.customerName;
    data['total_amount'] = this.totalAmount;
    data['booking_slot'] = this.bookingSlot;
    // data['timeslot_id'] = this.bookingSlot;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['description'] = this.description;
    data['discount'] = this.discount;
    data['duration_diff'] = this.durationDiff;
    data['duration_diff_hour'] = this.durationDiffHour;
    data['id'] = this.id;
    data['payment_id'] = this.paymentId;
    data['payment_method'] = this.paymentMethod;
    data['payment_status'] = this.paymentStatus;
    data['provider_id'] = this.providerId;
    data['provider_name'] = this.providerName;
    data['quantity'] = this.quantity;
    data['service_id'] = this.serviceId;
    data['service_name'] = this.serviceName;
    data['status'] = this.status;
    data['status_label'] = this.statusLabel;
    data['type'] = this.type;
    data['reason'] = this.reason;
    data['total_review'] = this.totalReview;
    data['total_rating'] = this.totalRating;
    data['start_at'] = this.startAt;
    data['end_at'] = this.endAt;
    data['booking_type'] = this.bookingType;
    data[AdvancePaymentKey.advancePaidAmount] = this.amount;
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    data['txn_id'] = this.txnId;
    data['tip_amount'] = this.tipAmount;

    if (addressDetails != null) {
      data['address_details'] = this.addressDetails!.toJson();
    }

    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    if (this.handyman != null) {
      data['handyman'] = this.handyman!.map((v) => v.toJson()).toList();
    }
    if (this.serviceAttachments != null) {
      data['service_attchments'] = this.serviceAttachments;
    }
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    if (this.extraCharges != null) {
      data['extra_charges'] = this.extraCharges!.map((v) => v.toJson()).toList();
    }
    if (bookingPackage != null) {
      data['booking_package'] = this.bookingPackage!.toJson();
    }
    if (category != null) {
      data['category'] = this.category!.toJson();
    }

    if (this.serviceaddon != null) {
      data['BookingAddonService'] = this.serviceaddon!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? nameAr;
  String? descriptionAr;
  String? description;
  String? color;
  int? status;
  int? isFeatured;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Category({this.id, this.name, this.nameAr, this.descriptionAr, this.description, this.color, this.status, this.isFeatured, this.deletedAt, this.createdAt, this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    nameAr = json['name_ar'] ?? '';
    descriptionAr = json['description_ar'];
    description = json['description'];
    color = json['color'];
    status = json['status'];
    isFeatured = json['is_featured'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_ar'] = this.nameAr;
    data['description_ar'] = this.descriptionAr;
    data['description'] = this.description;
    data['color'] = this.color;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
