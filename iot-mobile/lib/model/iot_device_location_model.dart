class IotDeviceLocationModel {
  final int? locationId;
  final String? locationName;
  final String? baseIp;
  final int? iotDeviceId;
  final String? iotDeviceName;
  final String? ip;
  final String? macAddress;

  IotDeviceLocationModel({
    this.locationId,
    this.locationName,
    this.baseIp,
    this.iotDeviceId,
    this.iotDeviceName,
    this.ip,
    this.macAddress,
  });

  factory IotDeviceLocationModel.fromJson(Map<String, dynamic> json) {
    return IotDeviceLocationModel(
      locationId: json['id'],
      locationName: json['location_name'],
      baseIp: json['baseIp'],
      iotDeviceId: json['iotDevice_id'],
      iotDeviceName: json['iotDevice_name'],
      ip: json['ip'],
      macAddress: json['macAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': locationId,
      'location_name': locationName,
      'baseIp': baseIp,
      'iotDevice_id': iotDeviceId,
      'iotDevice_name': iotDeviceName,
      'ip': ip,
      'macAddress': macAddress,
    };
  }
}
