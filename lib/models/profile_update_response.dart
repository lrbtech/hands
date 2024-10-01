import 'package:hands_user_app/models/user_data.dart';

class CommonResponseModel {
  UserDatas? data;
  String? message;

  CommonResponseModel({this.data, this.message});

  CommonResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new UserDatas.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}
