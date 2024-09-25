import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IotDeviceListScreen extends StatefulWidget {
  final baseIp;
  const IotDeviceListScreen({super.key, required this.baseIp});

  @override
  _IotDeviceListScreenState createState() => _IotDeviceListScreenState();
}

class _IotDeviceListScreenState extends State<IotDeviceListScreen> {
  List<dynamic> iotDeviceList = [];
  bool isLoading = false;

  Future<void> getiotDeviceList() async {
    setState(() {
      isLoading = true;
      iotDeviceList = [];
    });

    for (int i = 0; i <= 255; i++) {
      String ipAddress = '${widget.baseIp}$i';
      final response = await http.get(Uri.parse('http://$ipAddress/api'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            iotDeviceList.add({
              'id': data['id'],
              'macAddress': data['macAddress'],
            });
          });
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iotDevice Cihazları'),
      ),
      body: Column(
        children: [
          if (isLoading)
            CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: iotDeviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('ID: ${iotDeviceList[index]['id']}'),
                    subtitle: Text(
                        'MAC Address: ${iotDeviceList[index]['macAddress']}'),
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              getiotDeviceList();
            },
            child: Text('iotDevice Cihazlarını Bul'),
          ),
        ],
      ),
    );
  }
}
