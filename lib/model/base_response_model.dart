class BaseResponseModel {
  String? message;

  BaseResponseModel({this.message});

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    return data;
  }
}

class CouponBaseModel {
  String? message;
  String? messageAr;

  CouponBaseModel({this.message, this.messageAr});

  factory CouponBaseModel.fromJson(Map<String, dynamic> json) {
    return CouponBaseModel(
      message: json['message'] ?? '',
      messageAr: json['message_ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['message_ar'] = this.messageAr;
    return data;
  }
}
