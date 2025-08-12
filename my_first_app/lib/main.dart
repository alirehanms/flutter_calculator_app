
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:http/http.dart' as http;
import 'history_screen.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _history = '';
  String _expression = '';

  void _numClick(String text) {
    setState(() {
      _expression += text;
    });
  }

  void _allClear(String text) {
    setState(() {
      _history = '';
      _expression = '';
    });
  }

  void _clear(String text) {
    setState(() {
      _expression = '';
    });
  }

  void _evaluate(String text) async {
    Parser p = Parser();
    Expression exp = p.parse(_expression);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    String history = _expression;
    String expression = eval.toString();

    // Send to backend
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.14:3000/history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'expression': history,
          'result': expression,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          _history = history;
          _expression = expression;
        });
      } else {
        // Handle error
        print('Failed to save history. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 12.0),
            child: Text(
              _history,
              style: TextStyle(fontSize: 24.0, color: Colors.grey),
            ),
            alignment: Alignment(1.0, 1.0),
          ),
          Container(
            padding: EdgeInsets.all(12.0),
            child: Text(
              _expression,
              style: TextStyle(fontSize: 48.0),
            ),
            alignment: Alignment(1.0, 1.0),
          ),
          SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalculatorButton(
                text: 'AC',
                fillColor: 0xFF6C807F,
                textColor: 0xFFFFFFFF,
                callback: _allClear,
              ),
              CalculatorButton(
                text: 'C',
                fillColor: 0xFF6C807F,
                textColor: 0xFFFFFFFF,
                callback: _clear,
              ),
              CalculatorButton(
                text: '%',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                callback: _numClick,
              ),
              CalculatorButton(
                text: '/',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                callback: _numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalculatorButton(
                text: '7',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '8',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '9',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '*',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                textSize: 24,
                callback: _numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalculatorButton(
                text: '4',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '5',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '6',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '-',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                textSize: 38,
                callback: _numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalculatorButton(
                text: '1',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '2',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '3',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '+',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                textSize: 30,
                callback: _numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalculatorButton(
                text: '.',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '0',
                callback: _numClick,
              ),
              CalculatorButton(
                text: '00',
                callback: _numClick,
                textSize: 26,
              ),
              CalculatorButton(
                text: '=',
                fillColor: 0xFFFFFFFF,
                textColor: 0xFF65BDAC,
                callback: _evaluate,
              ),
            ],
          )
        ],
      ),
    );
  }
}


class CalculatorButton extends StatelessWidget {
  final String text;
  final int fillColor;
  final int textColor;
  final double textSize;
  final Function callback;

  const CalculatorButton({
    Key? key,
    required this.text,
    this.fillColor = 0xFFFFFFFF,
    this.textColor = 0xFF000000,
    this.textSize = 20.0,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: SizedBox(
        width: 65.0,
        height: 65.0,
        child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            backgroundColor: fillColor != null ? Color(fillColor) : null,
            foregroundColor: Color(textColor),
          ),
          onPressed: () => callback(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: textSize,
            ),
          ),
        ),
      ),
    );
  }
}