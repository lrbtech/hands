import 'package:hands_user_app/models/pagination_model.dart';
import 'package:hands_user_app/models/user_data.dart';

class UserListResponse {
  Pagination? pagination;
  List<UserDatas>? data;

  UserListResponse({this.pagination, this.data});

  UserListResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new UserDatas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
