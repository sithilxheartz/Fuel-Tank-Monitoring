import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Sensor Monitor',
      theme: ThemeData.dark(),
      home: SensorDisplay(),
    );
  }
}

class SensorDisplay extends StatefulWidget {
  @override
  _SensorDisplayState createState() => _SensorDisplayState();
}

class _SensorDisplayState extends State<SensorDisplay> {
  double? temperature;
  double? mqVoltage;
  int? mqRaw;

  final DatabaseReference tempRef = FirebaseDatabase.instance.ref(
    'esp32/temperature',
  );
  final DatabaseReference voltageRef = FirebaseDatabase.instance.ref(
    'esp32/mq135_voltage',
  );
  final DatabaseReference rawRef = FirebaseDatabase.instance.ref(
    'esp32/mq135_raw',
  );

  @override
  void initState() {
    super.initState();

    tempRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        temperature = double.tryParse(value.toString());
      });
    });

    voltageRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        mqVoltage = double.tryParse(value.toString());
      });
    });

    rawRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        mqRaw = int.tryParse(value.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ESP32 Sensor Monitor")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              temperature == null
                  ? CircularProgressIndicator()
                  : Text(
                    "🌡️ Temperature: ${temperature!.toStringAsFixed(2)} °C",
                    style: TextStyle(fontSize: 26),
                  ),
              SizedBox(height: 30),
              mqVoltage == null
                  ? CircularProgressIndicator()
                  : Text(
                    "🟢 MQ-135 Voltage: ${mqVoltage!.toStringAsFixed(3)} V",
                    style: TextStyle(fontSize: 26),
                  ),
              SizedBox(height: 30),
              mqRaw == null
                  ? CircularProgressIndicator()
                  : Text(
                    "📈 MQ-135 Raw ADC: $mqRaw",
                    style: TextStyle(fontSize: 26),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
