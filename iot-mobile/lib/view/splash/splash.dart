import 'package:flutter/material.dart';
import 'package:mpu_sql/view/home/home.dart';
import 'package:mpu_sql/view/onboard/onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _isShow;

  @override
  void initState() {
    super.initState();
    _isShow = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('onboard') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Splash Page"),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 2), () async {
      int onboardValue = await _isShow;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              onboardValue != 0 ? const HomePage() : const OnBoard(),
        ),
      );
    });
  }
}
