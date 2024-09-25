import 'package:flutter/material.dart';
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/model/location_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:mpu_sql/widget/home/iot_device_list_type.dart';
import 'package:mpu_sql/widget/home/location_text.dart';
import 'package:provider/provider.dart';

class TestController extends StatefulWidget {
  const TestController({Key? key}) : super(key: key);

  @override
  State<TestController> createState() => _TestControllerState();
}

class _TestControllerState extends State<TestController> {
  late Future _locationList;

  @override
  void initState() {
    super.initState();
    _locationList = _getLocationList();
    _getiotDeviceList();
  }

  Future _getLocationList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchLocations();
  }

  Future _getiotDeviceList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchiotDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Controller'),
      ),
      body: FutureBuilder(
        future: _locationList,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              final List<LocationModel> locations =
                  snapshot.data as List<LocationModel>;
              return ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final LocationModel location = locations[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: LocationText(location: location),
                          ),
                          Consumer<DatabaseProvider>(
                            builder: (context, db, child) {
                              final List<IotDeviceModel> iotDevices = db
                                  .iotDevices
                                  .where((iotDevice) =>
                                      iotDevice.locationId == location.id)
                                  .toList();
                              return iotDevices.isNotEmpty
                                  ? IotDeviceListType(
                                      iotDevices: iotDevices,
                                      locationId: location.id!,
                                    )
                                  : ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Add iotDevice'),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
