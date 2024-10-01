import 'package:hands_user_app/models/Package_response.dart';
import 'package:hands_user_app/models/attachment_model.dart';
import 'package:hands_user_app/models/booking_detail_response.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/models/extra_charges_model.dart';
import 'package:hands_user_app/models/pagination_model.dart';
import 'package:hands_user_app/models/tax_list_response.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_data.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/utils/model_keys.dart';

class BookingListResponse {
  List<BookingDatas>? data;
  Pagination? pagination;

  BookingListResponse({required this.data, required this.pagination});

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => BookingDatas.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class BookingDataAddressModel {
  int? id;
  int? bookingId;
  String? address;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;

  BookingDataAddressModel({
    this.id,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
  });

  BookingDataAddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class BookingDatas {
  int? id;
  int? isUrgent;
  String? address;
  BookingDataAddressModel? addressModel;
  int? customerId;
  int? serviceId;
  int? providerId;
  int? quantity;
  String? type;
  num? discount;
  num? amount;
  String? status;
  String? statusLabel;
  String? description;
  String? bookingSlot;
  String? providerName;
  String? customerName;
  String? serviceName;
  String? paymentStatus;
  String? paymentMethod;
  String? date;
  String? durationDiff;
  int? paymentId;
  int? bookingAddressId;
  List<TaxData>? taxes;
  num? totalAmount;
  num? paidAmount;
  Category? category;
  String? durationDiffHour;
  List<Handyman>? handyman;
  List<String>? imageAttachments;
  List<Attachments>? serviceAttachments;
  CouponData? couponData;
  num? totalCalculatedPrice;

  int? totalReview;
  num? totalRating;
  int? isCancelled;
  String? reason;
  String? startAt;
  String? endAt;
  List<ExtraChargesModel>? extraCharges;
  String? bookingType;
  PackageData? bookingPackage;

  num? finalTotalServicePrice;
  num? finalTotalTax;
  num? finalSubTotal;
  num? finalDiscountAmount;
  num? finalCouponDiscountAmount;
  String? txnId;
  Commission? commission;
  num? tip;

  //Local
  double get totalAmountWithExtraCharges =>
      totalAmount.validate() +
      extraCharges
          .validate()
          .sumByDouble((e) => e.qty.validate() * e.price.validate());

  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isFreeService => type.validate() == SERVICE_TYPE_FREE;

  bool get isPostJob => bookingType == BOOKING_TYPE_USER_POST_JOB;

  bool get isPackageBooking => bookingPackage != null;

  bool get isAdvancePaymentDone => paidAmount.validate() != 0;

  bool get isFixedService => type.validate() == SERVICE_TYPE_FIXED;

  bool get canCustomerContact =>
      status != BookingStatusKeys.pending &&
      status != BookingStatusKeys.cancelled &&
      status != BookingStatusKeys.failed &&
      status != BookingStatusKeys.rejected &&
      status != BookingStatusKeys.waitingAdvancedPayment &&
      paymentId != null &&
      paymentStatus == 'paid';

  num get totalExtraChargeAmount =>
      extraCharges.validate().sumByDouble((e) => e.total.validate());

  List<ServiceAddon>? serviceaddon;

  BookingDatas({
    this.isUrgent,
    this.address,
    this.imageAttachments,
    this.customerId,
    this.bookingSlot,
    this.customerName,
    this.date,
    this.description,
    this.discount,
    this.amount,
    this.durationDiff,
    this.durationDiffHour,
    this.handyman,
    this.commission,
    this.couponData,
    this.category,
    this.tip,
    this.id,
    this.paymentId,
    this.paymentMethod,
    this.paymentStatus,
    this.providerId,
    this.providerName,
    //this.serviceAttachments,
    this.taxes,
    this.serviceId,
    this.serviceName,
    this.status,
    this.statusLabel,
    this.type,
    this.quantity,
    this.totalCalculatedPrice,
    this.bookingAddressId,
    this.totalAmount,
    this.totalReview,
    this.totalRating,
    this.isCancelled,
    this.reason,
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
    this.serviceaddon,
    this.txnId,
    this.addressModel,
  });

  factory BookingDatas.fromJson(Map<String, dynamic> json) {
    return BookingDatas(
      isUrgent: json['is_urgent'],
      addressModel: json['address_details'] != null
          ? BookingDataAddressModel.fromJson(json['address_details'])
          : null,
      address: json['address'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      commission: json['commission'] != null
          ? Commission.fromJson(json['commission'])
          : null,
      date: json['date'],
      description: json['description'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      discount: json['discount'],
      amount: json['amount'],
      bookingSlot: json['booking_slot'] ?? '',
      durationDiff: json['duration_diff'],
      durationDiffHour: json['duration_diff_hour'],
      handyman: json['handyman'] != null
          ? (json['handyman'] as List).map((i) => Handyman.fromJson(i)).toList()
          : [],
      id: json['id'],
      tip: json['tip_amount'],
      paymentId: json['payment_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      providerId: json['provider_id'],
      providerName: json['provider_name'],
      // service_attchments: json['service_attchments'] != null ? (json['service_attchments'] as List).map((i) => Attachments.fromJson(i)).toList() : null,
      //  image_attchments :json['attchments'],
      imageAttachments: json['service_attchments'] != null
          ? List<String>.from(json['service_attchments'])
          : null,
      //service_attchments: json['service_attchments'] != null ? new List<String>.from(json['service_attchments']) : null,
      taxes: json['taxes'] != null
          ? (json['taxes'] as List).map((i) => TaxData.fromJson(i)).toList()
          : null,
      couponData: json['coupon_data'] != null
          ? CouponData.fromJson(json['coupon_data'])
          : null,
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      status: json['status'],
      statusLabel: json['status_label'],
      quantity: json['quantity'],
      type: json['type'],
      bookingAddressId: json['booking_address_id'],
      totalAmount: json['total_amount'],
      totalReview: json['total_review'],
      totalRating: json['total_rating'],
      isCancelled: json['is_cancelled'],
      reason: json['reason'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      extraCharges: json['extra_charges'] != null
          ? (json['extra_charges'] as List)
              .map((i) => ExtraChargesModel.fromJson(i))
              .toList()
          : null,
      bookingType: json['booking_type'],
      bookingPackage: json['booking_package'] != null
          ? PackageData.fromJson(json['booking_package'])
          : null,
      paidAmount: json[AdvancePaymentKey.advancePaidAmount],
      finalTotalServicePrice: json['final_total_service_price'],
      finalTotalTax: json['final_total_tax'],
      finalSubTotal: json['final_sub_total'],

      finalDiscountAmount: json['final_discount_amount'],
      finalCouponDiscountAmount: json['final_coupon_discount_amount'],
      serviceaddon: json['BookingAddonService'] != null
          ? (json['BookingAddonService'] as List)
              .map((i) => ServiceAddon.fromJson(i))
              .toList()
          : null,
      txnId: json['txn_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_urgent'] = this.isUrgent;
    data['address_details'] = this.addressModel;
    data['customer_id'] = this.customerId;
    data['customer_name'] = this.customerName;
    data['category'] = this.category != null ? this.category!.toJson() : null;
    data['commission'] =
        this.commission != null ? this.commission!.toJson() : null;
    data['date'] = this.date;
    data['discount'] = this.discount;
    data['tip_amount'] = this.tip;
    data['amount'] = this.amount;
    data['duration_diff'] = this.durationDiff;
    data['id'] = this.id;
    data['booking_slot'] = this.bookingSlot;
    data['provider_id'] = this.providerId;
    data['provider_name'] = this.providerName;
    data['service_id'] = this.serviceId;
    data['service_name'] = this.serviceName;
    data['status'] = this.status;
    data['status_label'] = this.statusLabel;
    data['type'] = this.type;
    data['address'] = this.address;
    data['description'] = this.description;
    data['duration_diff_hour'] = this.durationDiffHour;
    data['handyman'] = this.handyman;
    data['payment_id'] = this.paymentId;
    data['payment_method'] = this.paymentMethod;
    data['payment_status'] = this.paymentStatus;
    // data['service_attchments'] = this.service_attchments;
    //  data['attchments'] = this.image_attchments;
    if (this.imageAttachments != null) {
      data['service_attchments'] = this.imageAttachments;
    }
    /* if (this.service_attchments != null) {
      data['service_attchments'] = this.service_attchments!.map((v) => v.toJson()).toList();
    }*/
    data['booking_address_id'] = this.bookingAddressId;
    data['quantity'] = this.quantity;
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    data['total_amount'] = this.totalAmount;
    data['total_review'] = this.totalReview;
    data['total_rating'] = this.totalRating;
    data['reason'] = this.reason;
    data['is_cancelled'] = this.isCancelled;
    data['start_at'] = this.startAt;
    data['end_at'] = this.endAt;
    if (this.extraCharges != null) {
      data['extra_charges'] =
          this.extraCharges!.map((v) => v.toJson()).toList();
    }
    data['booking_type'] = this.bookingType;
    data[AdvancePaymentKey.advancePaidAmount] = this.amount;
    if (bookingPackage != null) {
      data['booking_package'] = this.bookingPackage!.toJson();
    }
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    if (this.serviceaddon != null) {
      data['BookingAddonService'] =
          this.serviceaddon!.map((v) => v.toJson()).toList();
    }
    data['txn_id'] = this.txnId;
    return data;
  }
}

class Handyman {
  int? id;
  int? bookingId;
  int? handymanId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  UserData? handyman;

  Handyman(
      {this.id,
      this.bookingId,
      this.handymanId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.handyman});

  Handyman.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    handymanId = json['handyman_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    handyman = json['handyman'] != null
        ? new UserData.fromJson(json['handyman'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['handyman_id'] = this.handymanId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    if (this.handyman != null) {
      data['handyman'] = this.handyman!.toJson();
    }
    return data;
  }
}
