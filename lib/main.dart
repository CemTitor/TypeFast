import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppHomeState();
  }
}

// bir class veya değişken ismi _ ile başlıyorsa farklı dosyalardan import edilemez
//yalnız bu dosyada kullanılır.
class _MyAppHomeState extends State<MyAppHome> {
  String userName = '';
  int typedCharLength = 0;
  String lorem =
      'Lorem ipsu dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.            '
          .toLowerCase()
          .replaceAll(',', '')
          .replaceAll('.', '');
  int step = 0;
  int lastTypedAt;

  void updateLastTypedAt() {
    this.lastTypedAt = DateTime.now().millisecondsSinceEpoch;
  }

  void onStartClick() {
    setState(() {
      updateLastTypedAt();
      step++;
    });
    var timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;
      // GAME OVER
      setState(() {
        if (step == 1 && now - lastTypedAt > 4000) {
          timer.cancel();
          step++;
        }
        if (step != 1) {
          var url = Uri.parse("https://typecast.herokuapp.com/users/score");
          http.post(url, body: {
            'userName': userName,
            'score': typedCharLength.toString()
          });
          timer.cancel();
        }
      });
    });
  }

  void onType(String value) {
    updateLastTypedAt();
    String trimmedValue = lorem.trimLeft();
    setState(() {
      if (trimmedValue.indexOf(value) != 0) {
        step = 2;
      } else {
        typedCharLength = value.length;
      }
    });
  }

  void onUserNameType(String value) {
    setState(() {
      this.userName = value.substring(0, 5);
    });
  }

  void resetGame() {
    setState(() {
      typedCharLength = 0;
      step = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var shownWidget;

    if (step == 0) {
      shownWidget = <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 30,
            right: 30,
          ),
          child: Image(
            image: AssetImage('images/type.jpeg'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Welcome to the type fast. Your nickname must be at least 5 letters.',
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: TextField(
            autofocus: true,
            onChanged: onUserNameType,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Whats your nickname. ',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: ElevatedButton(
            child: Text('GO !'),
            onPressed: userName.length == 0 ? null : onStartClick,
          ),
        )
      ];
    } else if (step == 1) {
      shownWidget = <Widget>[
        Text('$typedCharLength Point'),
        Container(
          height: 40,
          child: Marquee(
            text: lorem,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 2,
              color: Colors.black,
            ),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 0.0,
            velocity: 80,
            startPadding: 100,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 32,
          ),
          child: TextField(
            // autofocus: true,
            onChanged: onType,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Lets Write',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text('If your keyboard has autocorrect, you may get an error.'),
        )
      ];
    } else if (step == 2) {
      shownWidget = <Widget>[
        Text(
          'Game over !\nYour score is : $typedCharLength',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        ElevatedButton(
          child: Text('Try again !'),
          onPressed: resetGame,
        )
      ];
    }
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Type Fast')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: shownWidget,
          ),
        ),
      ),
    );
  }
}
