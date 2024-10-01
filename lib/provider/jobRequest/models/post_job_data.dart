import '../../../models/service_model.dart';

class PostJobData {
  num? id;
  String? title;
  String? description;
  String? reason;
  AddressModel? address;
  String? date;
  num? price;
  num? jobPrice;
  num? providerId;
  num? customerId;
  String? status;
  String? customerName;
  String? createdAt;
  bool? canBid;
  List<ServiceData>? service;
  String? customerProfile;
  String? timeslot;
  String? timeslotAr;
  AddressModel? addressModel;
  int? isUrgent;
  Category? category;

  PostJobData({
    this.id,
    this.title,
    this.description,
    this.reason,
    this.price,
    this.providerId,
    this.category,
    this.customerId,
    this.status,
    this.canBid,
    this.service,
    this.jobPrice,
    this.createdAt,
    this.customerName,
    this.customerProfile,
    this.address,
    this.date,
    this.timeslot,
    this.timeslotAr,
    this.addressModel,
    this.isUrgent,
  });

  PostJobData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    reason = json['reason'];
    price = json['price'];
    jobPrice = json['job_price'];
    providerId = json['provider_id'];
    category = Category.fromJson(json['category']);
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    status = json['status'];
    customerProfile = json['customer_profile'];
    canBid = json['can_bid'];
    createdAt = json['created_at'];
    date = json['date'];
    isUrgent = json['is_urgent'];
    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service?.add(ServiceData.fromJson(v));
      });
    }
    address = json['address'] != null ? new AddressModel.fromJson(json['address']) : null;
    timeslot = json['timeslot'];
    timeslotAr = json['timeslot_ar'];
    addressModel = json['address_detail'] != null ? new AddressModel.fromJson(json['address_detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['address'] = address;
    map['timeslot'] = timeslot;
    map['category'] = category?.toJson();
    map['timeslot_ar'] = timeslotAr;
    map['is_urgent'] = isUrgent;
    // map ['longitude'] = longitude;
    // map['latitude'] = latitude;
    map['date'] = date;
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['reason'] = reason;
    map['price'] = price;
    map['job_price'] = jobPrice;
    map['provider_id'] = providerId;
    map['customer_id'] = customerId;
    map['status'] = status;
    map['customer_name'] = customerName;
    map['customer_profile'] = customerProfile;
    map['can_bid'] = canBid;
    map['created_at'] = createdAt;
    if (this.addressModel != null) {
      map['address_detail'] = this.addressModel!.toJson();
    }
    if (service != null) {
      map['service'] = service?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AddressModel {
  int? id;
  int? userId;
  String? name;
  String? address;
  String? street;
  String? villaNumber;
  String? flatNumber;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  AddressModel({this.id, this.userId, this.name, this.address, this.street, this.villaNumber, this.flatNumber, this.latitude, this.longitude, this.createdAt, this.updatedAt, this.deletedAt});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = int.parse(json['user_id'].toString());
    name = json['name'];
    address = json['address'];
    street = json['street'];
    villaNumber = json['villa_number'];
    flatNumber = json['flat_number'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['address'] = this.address;
    data['street'] = this.street;
    data['villa_number'] = this.villaNumber;
    data['flat_number'] = this.flatNumber;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
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
