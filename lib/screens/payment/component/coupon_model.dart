class CouponModel {
  int? bookingId;
  String? code;
  String? createdAt;
  String? deletedAt;
  int? discount;
  String? discountType;
  int? id;
  String? updatedAt;
  num? totalCalculatedValue;

  CouponModel({this.bookingId, this.code, this.createdAt, this.deletedAt, this.discount, this.discountType, this.id, this.updatedAt, this.totalCalculatedValue});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      bookingId: json['booking_id'],
      code: json['code'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      discount: json['discount'],
      discountType: json['discount_type'],
      id: json['id'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['code'] = this.code;
    data['created_at'] = this.createdAt;
    data['discount'] = this.discount;
    data['deleted_at'] = this.deletedAt;
    data['discount_type'] = this.discountType;
    data['id'] = this.id;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
