import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _origin = Location(
      name: "Sua localizacao", latitude: -18.9402339, longitude: -48.3409575);
  final _destination = Location(
      name: "Seu destino", latitude: -18.9297543, longitude: -48.2933346);

  MapboxNavigation _directions;
  bool _arrived = false;
  double _distanceRemaining, _durationRemaining;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapboxNavigation(onRouteProgress: (arrived) async {
      _distanceRemaining = await _directions.distanceRemaining;
      _durationRemaining = await _directions.durationRemaining;

      setState(() {
        _arrived = arrived;
      });
      if (arrived) {
        await Future.delayed(Duration(seconds: 3));
        await _directions.finishNavigation();
      }
    });

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text('Running on: $_platformVersion\n'),
            SizedBox(
              height: 60,
            ),
            RaisedButton(
              child: Text("Iniciar naveçaão"),
              onPressed: () async {
                await _directions.startNavigation(
                    origin: _origin,
                    destination: _destination,
                    mode: NavigationMode.drivingWithTraffic,
                    simulateRoute: true,
                    language: "pt-br",
                    units: VoiceUnits.imperial);
              },
            ),
            SizedBox(
              height: 60,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("Distancia: "),
                      Text(_distanceRemaining != null
                          ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles"
                          : "---")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text("Durancao: "),
                      Text(_durationRemaining != null
                          ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes"
                          : "---")
                    ],
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
