import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpu_sql/model/iot_device_data.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

class IotDeviceDetail extends StatefulWidget {
  final int id;
  final int locationId;
  final String ip;
  const IotDeviceDetail({
    Key? key,
    required this.id,
    required this.locationId,
    required this.ip,
  }) : super(key: key);

  @override
  State<IotDeviceDetail> createState() => _iotDeviceDetailState();
}

class _iotDeviceDetailState extends State<IotDeviceDetail> {
  late Future _iotDeviceList;
  late Future _iotDeviceListById;
  IotDeviceData? _iotDeviceData;

  bool _ledOn = false;
  bool _ledOn2 = false;
  bool _ledOn3 = false;

  String lineVoltage = 'N/A';
  String current = 'N/A';
  String freqBuffer = 'N/A';
  String activePower = 'N/A';
  String energyWatt = 'N/A';
  String energyKW = 'N/A';
  String temperature = 'N/A';
  String staticWaitDelay = 'N/A';
  String dynamicWaitDelay = 'N/A';
  String mcuTick = 'N/A';
  String iotDeviceSwVersion = 'N/A';
  String endisStatus = 'N/A';
  String endisStatusThree = 'N/A';
  String resetDelayTimeButtonStatus = 'N/A';
  String earthVoltage = 'N/A';
  String loadVoltage = 'N/A';
  String lineVoltageCalib = 'N/A';
  String lowCurrentCalib = 'N/A';
  String highCurrentCalib = 'N/A';
  String highCurrentZeroCalib = 'N/A';
  String freqCalib = 'N/A';
  String loadVoltageCalib = 'N/A';
  String earthVoltageCalib = 'N/A';
  String temperatureMcuCalib = 'N/A';

  late IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _iotDeviceList = _getiotDeviceList();
    _iotDeviceListById = _getiotDeviceListById();
    channel = IOWebSocketChannel.connect('ws://${widget.ip}/ws');
  }

  Future _getiotDeviceList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchiotDevices();
  }

  Future _getiotDeviceListById() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchiotDeviceById(widget.id);
  }

  void _toggleLed(int pin, bool state) async {
    final url = 'http://${widget.ip}/toggle/led?pin=$pin&state=$state';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        if (pin == 1) {
          _ledOn = !_ledOn;
        } else if (pin == 2) {
          _ledOn2 = !_ledOn2;
        } else {
          _ledOn3 = !_ledOn3;
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: const Text('LED durumu değiştirilemedi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iotDevice Detail'),
      ),
      body: Center(
        child: Column(
          children: [
            Consumer<DatabaseProvider>(
              builder: (context, db, child) {
                var list = db.iotDevices
                    .where((iotDevice) =>
                        iotDevice.locationId == widget.locationId &&
                        iotDevice.id != widget.id)
                    .toList();
                return SizedBox(
                  height: 70,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IotDeviceDetail(
                                  id: list[i].id!,
                                  locationId: list[i].locationId!,
                                  ip: list[i].ip!),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(list[i].name.toString()),
                            Text(list[i].ip.toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            FutureBuilder(
              future: _iotDeviceList,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<DatabaseProvider>(
                            builder: (context, db, child) {
                              var list = db.iotDevices
                                  .where((iotDevice) =>
                                      iotDevice.locationId ==
                                          widget.locationId &&
                                      iotDevice.id != widget.id)
                                  .toList();
                              return SizedBox(
                                height: 70,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                IotDeviceDetail(
                                                    id: list[i].id!,
                                                    locationId:
                                                        list[i].locationId!,
                                                    ip: list[i].ip!),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          FutureBuilder(
                            future: _iotDeviceList,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text(snapshot.error.toString()));
                                } else {
                                  return StreamBuilder(
                                    stream: channel.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        if (snapshot.error is FormatException) {
                                          print(
                                              'Incorrect JSON data: ${snapshot.error.toString()}');
                                        }
                                        return Center(
                                            child: Text(
                                                'An error occurred: ${snapshot.error}'));
                                      }

                                      if (snapshot.hasData) {
                                        var data = jsonDecode(
                                            snapshot.data.toString());

                                        lineVoltage =
                                            data['lineVoltage'].toString();
                                        current = data['current'].toString();
                                        freqBuffer =
                                            data['freqBuffer'].toString();
                                        activePower =
                                            data['activePower'].toString();
                                        energyWatt =
                                            data['energyWatt'].toString();
                                        energyKW = data['energyKW'].toString();
                                        temperature =
                                            data['temperature'].toString();
                                        staticWaitDelay =
                                            data['staticWaitDelay'].toString();
                                        dynamicWaitDelay =
                                            data['dynamicWaitDelay'].toString();
                                        mcuTick = data['mcuTick'].toString();
                                        iotDeviceSwVersion =
                                            data['iotDeviceSwVersion']
                                                .toString();
                                        endisStatus =
                                            data['endisStatus'].toString();
                                        endisStatusThree =
                                            data['endisStatusThree'].toString();
                                        resetDelayTimeButtonStatus =
                                            data['resetDelayTimeButtonStatus']
                                                .toString();
                                        earthVoltage =
                                            data['earthVoltage'].toString();
                                        loadVoltage =
                                            data['loadVoltage'].toString();
                                        lineVoltageCalib =
                                            data['lineVoltageCalib'].toString();
                                        lowCurrentCalib =
                                            data['lowCurrentCalib'].toString();
                                        highCurrentCalib =
                                            data['highCurrentCalib'].toString();
                                        highCurrentZeroCalib =
                                            data['highCurrentZeroCalib']
                                                .toString();
                                        freqCalib =
                                            data['freqCalib'].toString();
                                        loadVoltageCalib =
                                            data['loadVoltageCalib'].toString();
                                        earthVoltageCalib =
                                            data['earthVoltageCalib']
                                                .toString();
                                        temperatureMcuCalib =
                                            data['temperatureMcuCalib']
                                                .toString();
                                      }

                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('Line Voltage: $lineVoltage'),
                                            Text('Current: $current'),
                                            Text(
                                                'Frequency Buffer: $freqBuffer'),
                                            Text('Active Power: $activePower'),
                                            Text('Energy Watt: $energyWatt'),
                                            Text('Energy KW: $energyKW'),
                                            Text('Temperature: $temperature'),
                                            Text(
                                                'Static Wait Delay: $staticWaitDelay'),
                                            Text(
                                                'Dynamic Wait Delay: $dynamicWaitDelay'),
                                            Text('MCU Tick: $mcuTick'),
                                            Text(
                                                'iotDevice SW Version: $iotDeviceSwVersion'),
                                            Text('Endis Status: $endisStatus'),
                                            Text(
                                                'Endis Status Three: $endisStatusThree'),
                                            Text(
                                                'Reset Delay Time Button Status: $resetDelayTimeButtonStatus'),
                                            Text(
                                                'Earth Voltage: $earthVoltage'),
                                            Text('Load Voltage: $loadVoltage'),
                                            Text(
                                                'Line Voltage Calib: $lineVoltageCalib'),
                                            Text(
                                                'Low Current Calib: $lowCurrentCalib'),
                                            Text(
                                                'High Current Calib: $highCurrentCalib'),
                                            Text(
                                                'High Current Zero Calib: $highCurrentZeroCalib'),
                                            Text('Freq Calib: $freqCalib'),
                                            Text(
                                                'Load Voltage Calib: $loadVoltageCalib'),
                                            Text(
                                                'Earth Voltage Calib: $earthVoltageCalib'),
                                            Text(
                                                'Temperature MCU Calib: $temperatureMcuCalib'),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
