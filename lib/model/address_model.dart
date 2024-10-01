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
    userId = json['user_id'];
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
