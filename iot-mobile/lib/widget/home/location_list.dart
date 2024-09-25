import 'package:flutter/material.dart';
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/model/location_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:mpu_sql/widget/home/add_iot_device_button.dart';
import 'package:mpu_sql/widget/home/iot_device_list_type.dart';
import 'package:mpu_sql/widget/home/location_text.dart';

import 'package:provider/provider.dart';

class LocationList extends StatelessWidget {
  const LocationList({
    super.key,
    required this.locations,
  });

  final List<LocationModel> locations;

  @override
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: LocationText(location: location),
                ),
                Consumer<DatabaseProvider>(
                  builder: (context, db, child) {
                    final List<IotDeviceModel> iotDevices = db.iotDevices
                        .where(
                            (iotDevice) => iotDevice.locationId == location.id)
                        .toList();
                    if (iotDevices.isNotEmpty) {
                      return IotDeviceListType(
                          iotDevices: iotDevices, locationId: location.id!);
                    } else {
                      return const AddIotDeviceButton();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
