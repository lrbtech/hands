class AppConfigModel {
  List<Configurations>? configurations;

  AppConfigModel({
    this.configurations,
  });

  AppConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['configurations'] != null) {
      configurations = <Configurations>[];
      json['configurations'].forEach((v) {
        configurations!.add(new Configurations.fromJson(v));
      });
    }
  }
}

class Configurations {
  int? id;
  String? type;
  String? key;
  String? value;
  String? valueAr;

  Configurations({this.id, this.type, this.key, this.value, this.valueAr});

  Configurations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    key = json['key'];
    value = json['value'];
    valueAr = json['value_ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['key'] = this.key;
    data['value'] = this.value;
    data['value_ar'] = this.valueAr;
    return data;
  }
}
