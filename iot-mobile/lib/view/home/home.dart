import 'package:flutter/material.dart';
import 'package:mpu_sql/model/location_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:mpu_sql/view/wifi_check/wifi_check.dart';
import 'package:mpu_sql/widget/home/location_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future _locationList;
  final _formKey = GlobalKey<FormState>();

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
    void _showAddDialog() {
      final _nameController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Location'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final provider =
                        Provider.of<DatabaseProvider>(context, listen: false);
                    provider.addLocation(LocationModel(
                      name: _nameController.text,
                      baseIp: "Null",
                    ));
                    provider.fetchLocations();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
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
              ElevatedButton(
                onPressed: () {
                  _showAddDialog();
                },
                child: const Text('Add Location'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _locationList,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    final List<LocationModel> locations =
                        snapshot.data as List<LocationModel>;
                    return LocationList(locations: locations);
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
