class LocationModel {
  int? id;
  String? name;
  String? baseIp;

  LocationModel({this.id, this.name, this.baseIp});

  LocationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    baseIp = json['baseIp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['baseIp'] = baseIp;
    return data;
  }
}
