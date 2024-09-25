class IotDeviceModel {
  int? id;
  int? locationId;
  String? name;
  String? ip;
  String? macAddress;

  IotDeviceModel(
      {this.id, this.locationId, this.name, this.ip, this.macAddress});

  IotDeviceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    locationId = json['locationId'];
    name = json['name'];
    ip = json['ip'];
    macAddress = json['macAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['locationId'] = locationId;
    data['name'] = name;
    data['ip'] = ip;
    data['macAddress'] = macAddress;
    return data;
  }
}
