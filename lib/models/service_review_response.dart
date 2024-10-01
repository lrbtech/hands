import 'package:hands_user_app/models/booking_detail_response.dart';

class ServiceReviewResponse {
  List<RatingDatas>? data;

  ServiceReviewResponse({this.data});

  factory ServiceReviewResponse.fromJson(Map<String, dynamic> json) {
    return ServiceReviewResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => RatingDatas.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
