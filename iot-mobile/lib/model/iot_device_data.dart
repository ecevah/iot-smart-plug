class IotDeviceData {
  String? lineVoltage;
  String? current;
  String? freqBuffer;
  String? activePower;
  String? energyWatt;
  String? energyKw;
  String? temperature;
  String? staticWaitDelay;
  String? dynamicWaitDelay;
  String? mcuTick;
  String? iotDeviceSwVersion;
  String? endisStatus;
  String? endisStatusThree;
  String? resetDelayTimeButtonStatus;
  String? earthVoltage;
  String? loadVoltage;
  String? lineVoltageCalib;
  String? lowVoltageCalib;
  String? hightVoltageCalib;
  String? hightCurrentZeroCalib;
  String? freqCalib;
  String? loadVoltageCalib;
  String? earthVoltageCalib;
  String? tempeatureMcuCalib;

  IotDeviceData({
    this.lineVoltage,
    this.current,
    this.freqBuffer,
    this.activePower,
    this.energyWatt,
    this.energyKw,
    this.temperature,
    this.staticWaitDelay,
    this.dynamicWaitDelay,
    this.mcuTick,
    this.iotDeviceSwVersion,
    this.endisStatus,
    this.endisStatusThree,
    this.resetDelayTimeButtonStatus,
    this.earthVoltage,
    this.loadVoltage,
    this.lineVoltageCalib,
    this.lowVoltageCalib,
    this.hightVoltageCalib,
    this.hightCurrentZeroCalib,
    this.freqCalib,
    this.loadVoltageCalib,
    this.earthVoltageCalib,
    this.tempeatureMcuCalib,
  });

  IotDeviceData.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      // Gelen JSON verisini işle
      lineVoltage = json['lineVoltage'];
      current = json['current'];
      freqBuffer = json['freqBuffer'];
      activePower = json['activePower'];
      energyWatt = json['energyWatt'];
      energyKw = json['energyKw'];
      temperature = json['temperature'];
      staticWaitDelay = json['staticWaitDelay'];
      dynamicWaitDelay = json['dynamicWaitDelay'];
      mcuTick = json['mcuTick'];
      iotDeviceSwVersion = json['iotDeviceSwVersion'];
      endisStatus = json['endisStatus'];
      endisStatusThree = json['endisStatusThree'];
      resetDelayTimeButtonStatus = json['resetDelayTimeButtonStatus'];
      earthVoltage = json['earthVoltage'];
      loadVoltage = json['loadVoltage'];
      lineVoltageCalib = json['lineVoltageCalib'];
      lowVoltageCalib = json['lowVoltageCalib'];
      hightVoltageCalib = json['hightVoltageCalib'];
      hightCurrentZeroCalib = json['hightCurrentZeroCalib'];
      freqCalib = json['freqCalib'];
      loadVoltageCalib = json['loadVoltageCalib'];
      earthVoltageCalib = json['earthVoltageCalib'];
      tempeatureMcuCalib = json['tempeatureMcuCalib'];
    } else {
      // JSON verisi null ise varsayılan değerler ata
      lineVoltage = 'N/A';
      current = 'N/A';
      freqBuffer = 'N/A';
      activePower = 'N/A';
      energyWatt = 'N/A';
      energyKw = 'N/A';
      temperature = 'N/A';
      staticWaitDelay = 'N/A';
      dynamicWaitDelay = 'N/A';
      mcuTick = 'N/A';
      iotDeviceSwVersion = 'N/A';
      endisStatus = 'N/A';
      endisStatusThree = 'N/A';
      resetDelayTimeButtonStatus = 'N/A';
      earthVoltage = 'N/A';
      loadVoltage = 'N/A';
      lineVoltageCalib = 'N/A';
      lowVoltageCalib = 'N/A';
      hightVoltageCalib = 'N/A';
      hightCurrentZeroCalib = 'N/A';
      freqCalib = 'N/A';
      loadVoltageCalib = 'N/A';
      earthVoltageCalib = 'N/A';
      tempeatureMcuCalib = 'N/A';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lineVoltage'] = lineVoltage;
    data['current'] = current;
    data['freqBuffer'] = freqBuffer;
    data['activePower'] = activePower;
    data['energyWatt'] = energyWatt;
    data['energyKw'] = energyKw;
    data['temperature'] = temperature;
    data['staticWaitDelay'] = staticWaitDelay;
    data['dynamicWaitDelay'] = dynamicWaitDelay;
    data['mcuTick'] = mcuTick;
    data['iotDeviceSwVersion'] = iotDeviceSwVersion;
    data['endisStatus'] = endisStatus;
    data['endisStatusThree'] = endisStatusThree;
    data['resetDelayTimeButtonStatus'] = resetDelayTimeButtonStatus;
    data['earthVoltage'] = earthVoltage;
    data['loadVoltage'] = loadVoltage;
    data['lineVoltageCalib'] = lineVoltageCalib;
    data['lowVoltageCalib'] = lowVoltageCalib;
    data['hightVoltageCalib'] = hightVoltageCalib;
    data['hightCurrentZeroCalib'] = hightCurrentZeroCalib;
    data['freqCalib'] = freqCalib;
    data['loadVoltageCalib'] = loadVoltageCalib;
    data['earthVoltageCalib'] = earthVoltageCalib;
    data['tempeatureMcuCalib'] = tempeatureMcuCalib;
    return data;
  }
}
