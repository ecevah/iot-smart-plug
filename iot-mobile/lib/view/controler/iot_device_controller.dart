import 'package:flutter/material.dart';
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:provider/provider.dart';

class iotDeviceController extends StatefulWidget {
  const iotDeviceController({Key? key}) : super(key: key);

  @override
  State<iotDeviceController> createState() => _iotDeviceControllerState();
}

class _iotDeviceControllerState extends State<iotDeviceController> {
  late Future _iotDeviceList;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _iotDeviceList = _getiotDeviceList();
  }

  Future _getiotDeviceList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchiotDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iotDevice Controller'),
      ),
      body: FutureBuilder(
        future: _iotDeviceList,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Consumer<DatabaseProvider>(
                        builder: (context, db, child) {
                          var list = db.iotDevices;
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, i) => ListTile(
                              title: Text(list[i].name.toString()),
                              subtitle: Text(list[i].ip.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showUpdateDialog(context, list[i]);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteDialog(context, list[i].id!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: _showAddDialog,
                        child: const Text('Add Location'),
                      ),
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
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final locationController = TextEditingController();
    final macAddressController = TextEditingController();

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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'IP'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a base IP';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: macAddressController,
                  decoration: const InputDecoration(labelText: 'Mac Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a base IP';
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
                  provider.addiotDevice(IotDeviceModel(
                    //
                    name: nameController.text,
                    macAddress: macAddressController.text,
                    ip: ipController.text,
                    locationId: int.parse(locationController.text),
                  ));
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

  void _showUpdateDialog(BuildContext context, IotDeviceModel iotDevice) {
    TextEditingController nameController = TextEditingController();
    TextEditingController ipController = TextEditingController();
    TextEditingController locationIdController = TextEditingController();
    TextEditingController macAddressController = TextEditingController();
    nameController.text = iotDevice.name!;
    ipController.text = iotDevice.ip!;
    macAddressController.text = iotDevice.macAddress!;
    locationIdController.text = iotDevice.locationId.toString();

    final _updateFormKey =
        GlobalKey<FormState>(); // Form anahtarını güncelledik
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Location'),
          content: Form(
            key: _updateFormKey, // Güncel form anahtarını kullandık
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'IP'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a base IP';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: macAddressController,
                  decoration: const InputDecoration(labelText: 'Mac Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: locationIdController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a base IP';
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
                if (_updateFormKey.currentState!.validate()) {
                  final provider =
                      Provider.of<DatabaseProvider>(context, listen: false);
                  provider.updateiotDevice(
                    iotDevice.id!,
                    macAddressController.text,
                    ipController.text,
                    int.parse(locationIdController.text),
                    nameController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int locationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Location'),
          content: const Text('Are you sure you want to delete this location?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                final provider =
                    Provider.of<DatabaseProvider>(context, listen: false);
                provider.deleteLocation(locationId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
