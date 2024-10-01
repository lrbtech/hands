import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/model/pagination_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/user_data_model.dart';

class GetPostJobResponse {
  Pagination? pagination;
  List<PostJobData>? myPostJobData;

  GetPostJobResponse({this.pagination, this.myPostJobData});

  GetPostJobResponse.fromJson(dynamic json) {
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      myPostJobData = [];
      json['data'].forEach((v) {
        myPostJobData?.add(PostJobData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    if (myPostJobData != null) {
      map['data'] = myPostJobData?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PostJobData {
  num? id;
  String? title;
  String? description;
  String? reason;
  AddressModel? address;
  int? addressId;
  String? date;
  String? timeSlot;
  String? timeSlotAr;
  int? paymentId;
  Category? category;
  int? serviceId;
  num? price;
  num? jobPrice;
  num? providerId;
  num? customerId;
  String? status;
  bool? canBid;
  int? isUrgent;
  String? createdAt;
  List<ServiceData>? service;
  AddressModel? addressDetails;

  bool get isUrgentRequest => isUrgent == 1;

  PostJobData({
    this.id,
    this.title,
    this.description,
    this.reason,
    this.address,
    this.timeSlot,
    this.timeSlotAr,
    this.addressId,
    this.date,
    this.paymentId,
    this.serviceId,
    this.price,
    this.jobPrice,
    this.providerId,
    this.customerId,
    this.status,
    this.canBid,
    this.isUrgent,
    this.service,
    this.createdAt,
    this.addressDetails,
    this.category,
  });

  PostJobData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];

    category = json['category'] != null ? Category.fromJson(json['category']) : null;

    if (json['address'] != null) {
      address = AddressModel.fromJson(json['address']);
    }
    addressId = json['address_id'] != null ? (int.parse(json['address_id'].toString())) : null;
    date = json['date'];
    timeSlot = json['timeslot'];
    timeSlotAr = json['timeslot_ar'];
    reason = json['reason'];
    paymentId = json['payment_id'];
    serviceId = json['service_id'];
    price = json['price'];
    jobPrice = json['job_price'];
    providerId = json['provider_id'];
    customerId = json['customer_id'];
    status = json['status'];
    canBid = json['can_bid'];
    isUrgent = json['is_urgent'].runtimeType == String ? int.parse(json['is_urgent']) : (json['is_urgent']);
    createdAt = json['created_at'];
    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service?.add(ServiceData.fromJson(v));
      });
    }
    if (json['address_detail'] != null) {
      addressDetails = AddressModel.fromJson(json['address_detail']);
    }

    if (json['data'] != null) {
      address = AddressModel.fromJson(json['address']);
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isPublic'] = 1;
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['address'] = address;
    map['address_id'] = addressId;
    map['payment_id'] = paymentId;
    map['service_id'] = serviceId;
    map['date'] = date;
    map['reason'] = reason;
    map['price'] = price;
    map['job_price'] = jobPrice;
    map['provider_id'] = providerId;
    map['customer_id'] = customerId;
    map['status'] = status;
    map['can_bid'] = canBid;
    map['is_urgent'] = isUrgent;
    if (service != null) {
      map['service'] = service?.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      map['category'] = this.category!.toJson();
    }
    return map;
  }
}

class BidderData {
  int? id;
  int? postRequestId;
  int? providerId;
  num? price;
  String? duration;
  UserData? provider;

  BidderData({this.id, this.postRequestId, this.providerId, this.price, this.duration, this.provider});

  BidderData.fromJson(Map json) {
    id = json['id'];
    postRequestId = json['post_request_id'];
    providerId = json['provider_id'];
    price = json['price'];
    duration = json['duration'];
    provider = json['provider'] != null ? new UserData.fromJson(json['provider']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['post_request_id'] = this.postRequestId;
    data['provider_id'] = this.providerId;
    data['price'] = this.price;
    data['duration'] = this.duration;
    if (this.provider != null) {
      data['provider'] = this.provider!.toJson();
    }
    return data;
  }
}
