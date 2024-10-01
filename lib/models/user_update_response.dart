import 'package:hands_user_app/models/user_data.dart';

class UserUpdateResponse {
  UserDatas? data;
  String? message;

  UserUpdateResponse({this.data, this.message});

  UserUpdateResponse.fromJson(Map<String, dynamic> json) {
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
