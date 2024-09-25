import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpu_sql/model/iot_device_location_model.dart';
import 'package:mpu_sql/model/iot_device_model.dart';
import 'package:mpu_sql/model/location_model.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseProvider with ChangeNotifier {
  String _searchTextiotDevice = "";
  String get searchTextiotDevice => _searchTextiotDevice;
  set searchTextiotDevice(String value) {
    _searchTextiotDevice = value;
    notifyListeners();
  }

  String _searchTextLocation = "";
  String get searchTextLocation => _searchTextLocation;
  set searchTextLocation(String value) {
    _searchTextLocation = value;
    notifyListeners();
  }

  List<LocationModel> _locations = [];
  List<LocationModel> get locations {
    return _searchTextLocation != ""
        ? _locations
            .where((element) => element.name!
                .toLowerCase()
                .contains(_searchTextLocation.toLowerCase()))
            .toList()
        : _locations;
  }

  List<IotDeviceModel> _iotDevices = [];
  List<IotDeviceModel> get iotDevices {
    return _searchTextiotDevice != ""
        ? _iotDevices
            .where((element) => element.name!
                .toLowerCase()
                .contains(_searchTextiotDevice.toLowerCase()))
            .toList()
        : _iotDevices;
  }

  List<IotDeviceLocationModel> _iotDeviceLocation = [];
  List<IotDeviceLocationModel> get iotDevicesLocation => _iotDeviceLocation;

  Database? _database;
  Future<Database> get database async {
    final dbDirectory = await getDatabasesPath();

    const dbName = 'expense_tc.db';

    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return _database!;
  }

  static const lTable = "locationTable";
  static const mTable = "iotDeviceTable";

  Future<void> _createDb(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''CREATE TABLE $lTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT, 
          baseIp TEXT
          )''');

      await txn.execute('''CREATE TABLE $mTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          locationId INTEGER,
          name TEXT,
          ip TEXT,
          macAddress TEXT,
          FOREIGN KEY (locationId) REFERENCES $lTable(id)
      )''');
    });
  }

  Future<List<LocationModel>> fetchLocations() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(lTable).then((value) {
        final converted = List<Map<String, dynamic>>.from(value);

        List<LocationModel> nList = List.generate(
          converted.length,
          (index) => LocationModel.fromJson(converted[index]),
        );

        _locations = nList;
        return _locations;
      });
    });
  }

  Future<List<IotDeviceModel>> fetchiotDevices() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(mTable).then((value) {
        final converted = List<Map<String, dynamic>>.from(value);

        List<IotDeviceModel> nList = List.generate(
          converted.length,
          (index) => IotDeviceModel.fromJson(converted[index]),
        );

        _iotDevices = nList;
        return _iotDevices;
      });
    });
  }

  Future<void> updateLocation(
    int id,
    String nName,
    String nBaseIp,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        lTable,
        {'name': nName, 'baseIp': nBaseIp},
        where: 'id == ?',
        whereArgs: [id],
      )
          .then((_) {
        var file = _locations.firstWhere((element) => element.id == id);
        file.baseIp = nBaseIp;
        file.name = nName;
        notifyListeners();
      });
    });
  }

  Future<void> updateiotDevice(int id, String nMacAddress, String nIp,
      int nLocationId, String nName) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        mTable,
        {
          'name': nName,
          'ip': nIp,
          'locationId': nLocationId,
          'macAddress': nMacAddress,
        },
        where: 'id == ?',
        whereArgs: [id],
      )
          .then((_) {
        var file = _iotDevices.firstWhere((element) => element.id == id);
        file.ip = nIp;
        file.locationId = nLocationId;
        file.name = nName;
        file.macAddress = nMacAddress;
        notifyListeners();
      });
    });
  }

  Future<void> findAndModifyiotDevices(String baseIp) async {
    for (int i = 0; i <= 255; i++) {
      String ipAddress = '$baseIp$i';
      final response = await http.get(Uri.parse('http://$ipAddress/api'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == true) {
          String macAddress = data['macAddress'];
          await updateiotDeviceByMacAddress(macAddress, ipAddress);
        }
      }
    }
  }

  Future<void> updateiotDeviceByMacAddress(
      String macAddress, String nIp) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        mTable,
        {
          'ip': nIp,
        },
        where: 'macAddress == ?',
        whereArgs: [macAddress],
      )
          .then((_) {
        _iotDevices.forEach((file) {
          if (file.macAddress == macAddress) {
            file.ip = nIp;
          }
        });
        notifyListeners();
      });
    });
  }

  Future<void> addLocation(LocationModel location) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        lTable,
        location.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((value) {
        final file = LocationModel(
            id: value, name: location.name, baseIp: location.baseIp);

        _locations.add(file);
        notifyListeners();
      });
    });
  }

  Future<void> addiotDevice(IotDeviceModel iotDevice) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(mTable, iotDevice.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace)
          .then((value) {
        final file = IotDeviceModel(
            id: value,
            name: iotDevice.name,
            locationId: iotDevice.locationId,
            macAddress: iotDevice.macAddress,
            ip: iotDevice.ip);

        _iotDevices.add(file);
        notifyListeners();
      });
    });
  }

  Future<void> deleteLocation(int locationId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .delete(lTable, where: 'id == ?', whereArgs: [locationId]).then((_) {
        _locations.removeWhere((element) => element.id == locationId);
      });
      notifyListeners();
    });
  }

  Future<void> deleteiotDevice(int iotDeviceId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .delete(mTable, where: 'id == ?', whereArgs: [iotDeviceId]).then((_) {
        _iotDevices.removeWhere((element) => element.id == iotDeviceId);
      });
      notifyListeners();
    });
  }

  Future<void> fetchiotDeviceLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT iotDevices.id, iotDevices.name AS iotDeviceName, iotDevices.ip, iotDevices.macAddress, locations.name AS locationName, locations.baseIp AS baseIp
    FROM iotDevices
    JOIN locations ON iotDevices.locationId = locations.id
  ''');

    List<IotDeviceLocationModel> iotDeviceLocations = [];
    for (Map<String, dynamic> row in result) {
      iotDeviceLocations.add(IotDeviceLocationModel(
        locationId: row['locationId'],
        locationName: row['locationName'],
        baseIp: row['baseIp'],
        iotDeviceId: row['id'],
        iotDeviceName: row['iotDeviceName'],
        ip: row['ip'],
        macAddress: row['macAddress'],
      ));
    }

    _iotDeviceLocation = iotDeviceLocations;
    notifyListeners();
  }

  Future<IotDeviceModel?> fetchiotDeviceById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      mTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return IotDeviceModel.fromJson(result.first);
    } else {
      return IotDeviceModel();
    }
  }

  Future<LocationModel?> fetchLocationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      lTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return LocationModel.fromJson(result.first);
    } else {
      return LocationModel();
    }
  }

  Future<IotDeviceModel> fetchiotDeviceByLocation(int location) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      mTable,
      where: 'locationId = ?',
      whereArgs: [location],
    );

    if (result.isNotEmpty) {
      return IotDeviceModel.fromJson(result.first);
    } else {
      return IotDeviceModel();
    }
  }
}
