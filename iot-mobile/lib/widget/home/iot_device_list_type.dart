import 'package:flutter/material.dart';
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/view/iot_device_detail/iot_device_detail.dart';

class IotDeviceListType extends StatelessWidget {
  const IotDeviceListType({
    super.key,
    required this.iotDevices,
    required this.locationId,
  });

  final List<IotDeviceModel> iotDevices;
  final int locationId;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: iotDevices
          .map(
            (iotDevice) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IotDeviceDetail(
                      id: iotDevice.id!,
                      locationId: locationId,
                      ip: iotDevice.ip!,
                    ),
                  ),
                );
              },
              child: ListTile(
                title: Text(iotDevice.name ?? ''),
                subtitle: Text(iotDevice.ip ?? ''),
              ),
            ),
          )
          .toList(),
    );
  }
}
