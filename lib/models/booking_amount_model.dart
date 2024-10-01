import 'package:hands_user_app/models/service_model.dart';

class BookingAmountModel {
  num finalTotalServicePrice;
  num finalTotalTax;
  num finalSubTotal;
  num finalServiceAddonAmount;
  num finalDiscountAmount;
  num finalCouponDiscountAmount;
  num finalGrandTotalAmount;

  BookingAmountModel({
    this.finalTotalServicePrice = 0,
    this.finalTotalTax = 0,
    this.finalSubTotal = 0,
    this.finalServiceAddonAmount = 0,
    this.finalDiscountAmount = 0,
    this.finalCouponDiscountAmount = 0,
    this.finalGrandTotalAmount = 0,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    return data;
  }

  Map<String, dynamic> toBookingUpdateJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    data['total_amount'] = this.finalGrandTotalAmount;
    return data;
  }
}

class Serviceaddon {
  int id;
  String name;
  String serviceAddonImage;
  int serviceId;
  num price;
  int status;
  String deletedAt;
  String createdAt;
  String updatedAt;
  bool isSelected = false;

  Serviceaddon({
    this.id = -1,
    this.name = "",
    this.serviceAddonImage = "",
    this.serviceId = -1,
    this.price = 0,
    this.status = -1,
    this.deletedAt = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Serviceaddon.fromJson(Map<String, dynamic> json) {
    return Serviceaddon(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : "",
      serviceAddonImage: json['serviceaddon_image'] is String
          ? json['serviceaddon_image']
          : "",
      serviceId: json['service_id'] is int ? json['service_id'] : -1,
      price: json['price'] is num ? json['price'] : 0,
      status: json['status'] is int ? json['status'] : -1,
      deletedAt: json['deleted_at'] is String ? json['created_at'] : "",
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serviceaddon_image': serviceAddonImage,
      'service_id': serviceId,
      'price': price,
      'status': status,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BookingPackage {
  int? id;
  String? name;
  String? description;
  num? price;
  String? startDate;
  String? endDate;
  List<ServiceData>? serviceList;
  var isFeatured;
  int? categoryId;
  List<BookingAttachments>? attchments;
  List<String>? imageAttachments;
  int? status;
  String? packageType;

  BookingPackage({
    this.id,
    this.name,
    this.description,
    this.price,
    this.startDate,
    this.endDate,
    this.serviceList,
    this.isFeatured,
    this.categoryId,
    this.attchments,
    this.imageAttachments,
    this.status,
    this.packageType,
  });

  BookingPackage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    if (json['services'] != null) {
      serviceList = [];
      json['services'].forEach((v) {
        serviceList!.add(ServiceData.fromJson(v));
      });
    }
    attchments = json['attchments_array'] != null
        ? (json['attchments_array'] as List)
            .map((i) => BookingAttachments.fromJson(i))
            .toList()
        : null;
    imageAttachments = json['attchments'] != null
        ? List<String>.from(json['attchments'])
        : null;
    categoryId = json['category_id'];
    isFeatured = json['is_featured'];
    packageType = json['package_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['status'] = this.status;
    data['package_type'] = this.packageType;
    if (this.serviceList != null) {
      data['services'] = this.serviceList!.map((v) => v.toJson()).toList();
    }
    data['category_id'] = this.categoryId;
    data['is_featured'] = this.isFeatured;
    if (this.attchments != null) {
      data['attchments_array'] =
          this.attchments!.map((v) => v.toJson()).toList();
    }
    if (this.imageAttachments != null) {
      data['attchments'] = this.imageAttachments;
    }
    return data;
  }
}

class BookingAttachments {
  int? id;
  String? url;

  BookingAttachments({this.id, this.url});

  factory BookingAttachments.fromJson(Map<String, dynamic> json) {
    return BookingAttachments(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}
