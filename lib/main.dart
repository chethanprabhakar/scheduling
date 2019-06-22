import 'dart:async';

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// IMPORTANT: running the following code on its own won't work as there is setup required for each platform head project.
/// Please download the complete example app from the GitHub repository where all the setup has been done
void main() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
  // change the default route of the app
  // var notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}

class PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  const PaddedRaisedButton(
      {@required this.buttonText, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: RaisedButton(child: Text(buttonText), onPressed: onPressed),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var platform = MethodChannel('crossingthestreams.io/resourceResolver');

  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<HomePage> validateAndSave() async {
    try {
      _showNotification() async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'ticker');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0, 'plain title', 'plain body', platformChannelSpecifics,
            payload: 'item x');
      }

      _cancelNotification() async {
        await flutterLocalNotificationsPlugin.cancel(0);
      }

      _scheduleNotification() async {
        print('here in one time notification');
        var scheduledNotificationDateTime =
            DateTime.now().add(Duration(seconds: 5));
        var vibrationPattern = Int64List(4);
        vibrationPattern[0] = 0;
        vibrationPattern[1] = 1000;
        vibrationPattern[2] = 5000;
        vibrationPattern[3] = 2000;

        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          'your channel description',
          /* icon: 'secondary_icon',
                sound: 'slow_spring_board',
                largeIcon: 'sample_large_icon',
                largeIconBitmapSource: BitmapSource.Drawable,
                vibrationPattern: vibrationPattern,
                enableLights: true,
                color: const Color.fromARGB(255, 255, 0, 0),
                ledColor: const Color.fromARGB(255, 255, 0, 0),
                ledOnMs: 1000,
                ledOffMs: 500 */
        );
        var iOSPlatformChannelSpecifics =
            IOSNotificationDetails(sound: "slow_spring_board.aiff");
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.schedule(
            0,
            'plain title',
            'plain body',
            scheduledNotificationDateTime,
            platformChannelSpecifics);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scheduling Notifications'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text(
                        'Tap on a notification when it appears to trigger navigation'),
                  ),
                  PaddedRaisedButton(
                      buttonText:
                          'Schedule notification to appear in 5 seconds, custom sound, red colour, large icon, red LED',
                      onPressed: () async {
                        await validateAndSave();
                      }),
                  /* PaddedRaisedButton(
                    buttonText: 'Repeat notification every minute',
                    onPressed: () async {
                      await validateAndSave();
                    },
                  ), */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondScreen(payload),
                    ),
                  );
                },
              )
            ],
          ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen with payload: " + _payload),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
