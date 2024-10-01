import 'package:hands_user_app/models/pagination_model.dart';

class SignUpCategoriesModel {
  Pagination? pagination;
  List<SignUpCategory>? data;

  SignUpCategoriesModel({this.pagination, this.data});

  SignUpCategoriesModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new SignUpCategory.fromJson(v));
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

class SignUpCategory {
  int? id;
  String? name;
  String? nameAr;
  int? status;
  String? description;
  String? descriptionAr;
  int? isFeatured;
  String? color;
  String? categoryImage;
  String? categoryExtension;
  int? services;
  String? deletedAt;

  SignUpCategory({
    this.id,
    this.name,
    this.nameAr,
    this.status,
    this.description,
    this.descriptionAr,
    this.isFeatured,
    this.color,
    this.categoryImage,
    this.categoryExtension,
    this.services,
    this.deletedAt,
  });

  //CategoryData({this.id, this.name, this.status, this.description, this.isFeatured, this.color, this.categoryImage});

  SignUpCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    status = json['status'];
    description = json['description'];
    descriptionAr = json['description_ar'];
    isFeatured = json['is_featured'];
    color = json['color'];
    categoryImage = json['category_image'];
    categoryExtension = json['category_extension'];
    services = json['services'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_ar'] = this.nameAr;
    data['status'] = this.status;
    data['description'] = this.description;
    data['description_ar'] = this.descriptionAr;
    data['is_featured'] = this.isFeatured;
    data['color'] = this.color;
    data['category_image'] = this.categoryImage;
    data['category_extension'] = this.categoryExtension;
    data['services'] = this.services;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
