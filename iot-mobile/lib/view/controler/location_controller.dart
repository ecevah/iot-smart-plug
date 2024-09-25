import 'package:flutter/material.dart';
import 'package:mpu_sql/model/location_model.dart';
import 'package:mpu_sql/services/provider.dart';
import 'package:provider/provider.dart';

class LocationController extends StatefulWidget {
  const LocationController({Key? key}) : super(key: key);

  @override
  State<LocationController> createState() => _LocationControllerState();
}

class _LocationControllerState extends State<LocationController> {
  late Future _locationList;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _locationList = _getLocationList();
  }

  Future _getLocationList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Controller'),
      ),
      body: FutureBuilder(
        future: _locationList,
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
                          var list = db.locations;
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, i) => ListTile(
                              title: Text(list[i].name.toString()),
                              subtitle: Text(list[i].baseIp.toString()),
                              leading: Text(list[i].id.toString()),
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
    final _nameController = TextEditingController();
    final _baseIpController = TextEditingController();

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
                TextFormField(
                  controller: _baseIpController,
                  decoration: const InputDecoration(labelText: 'Base IP'),
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
                  provider.addLocation(LocationModel(
                    name: _nameController.text,
                    baseIp: _baseIpController.text,
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

  void _showUpdateDialog(BuildContext context, LocationModel location) {
    TextEditingController nameController =
        TextEditingController(); // name controller
    TextEditingController baseIpController =
        TextEditingController(); // baseIp controller
    nameController.text = location.name!;
    baseIpController.text = location.baseIp!;
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
                  controller: baseIpController,
                  decoration: const InputDecoration(labelText: 'Base IP'),
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
                  provider.updateLocation(
                    location.id!, // Güncellenen konumun adını kullanıyoruz
                    nameController.text,
                    baseIpController.text,
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
