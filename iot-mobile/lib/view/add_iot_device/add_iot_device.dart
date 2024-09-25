import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:mpu_sql/view/home/home.dart';
import 'package:provider/provider.dart';

class WiFiScanner extends StatefulWidget {
  const WiFiScanner({super.key});

  @override
  _WiFiScannerState createState() => _WiFiScannerState();
}

class _WiFiScannerState extends State<WiFiScanner> {
  int selectedLocationId = 1;
  Future<List<Map<String, dynamic>>> fetchWifiData() async {
    final response = await http.get(Uri.parse('http://192.168.4.1/scan'));

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      final decodedData = json.decode(data);
      return List<Map<String, dynamic>>.from(decodedData['data']);
    } else {
      throw Exception('Failed to load WiFi data');
    }
  }

  void connectToWiFi(String ssid) async {
    showDialog(
      context: context,
      builder: (context) {
        String password = '';
        return AlertDialog(
          title: Text('Connect to $ssid'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  password = value;
                },
                decoration: const InputDecoration(labelText: 'Enter password'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedLocationId,
                onChanged: (value) {
                  setState(() {
                    selectedLocationId = value!;
                  });
                },
                items: Provider.of<DatabaseProvider>(context)
                    .locations
                    .map((location) {
                  return DropdownMenuItem<int>(
                    value: location.id!,
                    child: Text(location.name!),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://192.168.4.1/connect'),
                  body: json.encode({'ssid': ssid, 'password': password}),
                  headers: {'Content-Type': 'application/json'},
                );
                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['status'] == 'true') {
                    final provider =
                        Provider.of<DatabaseProvider>(context, listen: false);
                    provider.addiotDevice(IotDeviceModel(
                      name: 'iotDevice-${responseData['macAddress']}',
                      macAddress: responseData['macAddress'],
                      ip: responseData['ip'],
                      locationId: selectedLocationId,
                    ));

                    // Güncelleme işlemi
                    final location = provider.locations
                        .firstWhere((loc) => loc.id == selectedLocationId);
                    if (location.baseIp == "Null") {
                      final ipParts = responseData['ip'].split('.');
                      if (ipParts.length == 4) {
                        location.baseIp =
                            '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.';
                        provider.updateLocation(
                            location.id!, location.name!, location.baseIp!);
                      }
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connected to $ssid')),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to connect')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to connect')),
                  );
                }
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Scanner'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWifiData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromRGBO(106, 152, 181, 1),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> wifiList = snapshot.data!;
            return ListView.builder(
              itemCount: wifiList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    String ssid = wifiList[index]['ssid'];
                    connectToWiFi(ssid);
                  },
                  child: ListTile(
                    title: Text(
                      wifiList[index]['ssid'],
                      style: const TextStyle(fontFamily: 'Roboto'),
                    ),
                    subtitle: Text(
                      'RSSI: ${wifiList[index]['rssi']}',
                      style: const TextStyle(fontFamily: 'Roboto'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
