import 'package:flutter/material.dart';
import 'package:mpu_sql/view/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _counter = 0;

  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _counter = (prefs.getInt('onboard') ?? 0) + 1;
      prefs.setInt('onboard', _counter);
    });
  }

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      _counter = prefs.getInt('onboard') ?? 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("OnBoard"),
            ElevatedButton(
              onPressed: () async {
                await _incrementCounter();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text("Skip"),
            )
          ],
        ),
      ),
    );
  }
}
