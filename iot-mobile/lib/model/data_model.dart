class DataModel {
  int? id;
  int? iotDeviceId;
  double? voltage;
  double? current;
  double? frequency;
  double? activePower;
  double? wh;
  double? kwh;
  double? temperature;
  double? delay;

  DataModel(
      {this.id,
      this.iotDeviceId,
      this.voltage,
      this.current,
      this.frequency,
      this.activePower,
      this.wh,
      this.kwh,
      this.temperature,
      this.delay});

  DataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iotDeviceId = json['iotDevice_id'];
    voltage = json['voltage'];
    current = json['current'];
    frequency = json['frequency'];
    activePower = json['activePower'];
    wh = json['wh'];
    kwh = json['kwh'];
    temperature = json['temperature'];
    delay = json['delay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['iotDevice_id'] = iotDeviceId;
    data['voltage'] = voltage;
    data['current'] = current;
    data['frequency'] = frequency;
    data['activePower'] = activePower;
    data['wh'] = wh;
    data['kwh'] = kwh;
    data['temperature'] = temperature;
    data['delay'] = delay;
    return data;
  }
}
