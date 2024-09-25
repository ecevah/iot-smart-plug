import 'package:flutter/material.dart';
import 'package:mpu_sql/view/wifi_check/wifi_check.dart';

class AddIotDeviceButton extends StatelessWidget {
  const AddIotDeviceButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WifiCheck(),
              ),
            );
          },
          child: const Text('Add iotDevice'),
        ),
      ),
    );
  }
}
