//  Copyright (c) 2021 Kfir Matityahu
//  Licensed under Apache License v2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:streams_channel2/streams_channel2.dart';

void main() => runApp(MyApp());

final StreamsChannel streamsChannel = StreamsChannel('streams_channel_example');

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<dynamic>? _subscriptionA;
  StreamSubscription<dynamic>? _subscriptionB;

  void _start(bool a) {
    // ignore: cancel_subscriptions
    StreamSubscription<dynamic>? subscription =
        a ? _subscriptionA : _subscriptionB;

    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    } else {
      final streamId = 'Stream ${a ? 'A' : 'B'}';
      subscription = streamsChannel
          .receiveBroadcastStream(streamId)
          .listen((data) => debugPrint('Received from $streamId: $data'));

      subscription.onDone(() {
        setState(() {
          if (a) {
            _subscriptionA = null;
          } else {
            _subscriptionB = null;
          }
        });
      });
    }

    setState(() {
      if (a) {
        _subscriptionA = subscription;
      } else {
        _subscriptionB = subscription;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () => _start(true),
                child: Text(_subscriptionA != null ? 'Stop A' : 'Start A'),
              ),
              FlatButton(
                onPressed: () => _start(false),
                child: Text(_subscriptionB != null ? 'Stop B' : 'Start B'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
