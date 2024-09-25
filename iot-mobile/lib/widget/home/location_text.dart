import 'package:flutter/material.dart';
import 'package:mpu_sql/model/location_model.dart';

class LocationText extends StatelessWidget {
  const LocationText({
    super.key,
    required this.location,
  });

  final LocationModel location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Location Name: ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          location.name ?? '',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
