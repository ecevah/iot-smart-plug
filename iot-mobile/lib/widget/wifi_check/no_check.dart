import 'package:flutter/material.dart';
import 'package:mpu_sql/view/add_mpu/add_mpu.dart';

class Checked extends StatelessWidget {
  const Checked({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("MPU-XXX-XXX adlı ağa bağlandınız."),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WiFiScanner()),
            );
          },
          child: const Text("MPU-XXX-XXX adlı ağa bağlandım."),
        ),
      ],
    );
  }
}
