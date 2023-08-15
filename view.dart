import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class trainRegistpage extends StatefulWidget {
  trainRegistpage({
    Key? key,
    this.train,
  }) : super(key: key);
  dynamic train;

  @override
  State<trainRegistpage> createState() => _trainRegistPageState();
}


class _trainRegistPageState extends State<trainRegistpage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Scaffold(
      appBar: AppBar(
            centerTitle: true,
            title: Title(
                color: Color.fromRGBO(87, 87, 87, 1),
                child: Text(
                  '훈련 관리',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          
          body: SafeArea(
            top: true,
            child: Column(
              children: [
                Text(
                            "?",
                            style: TextStyle(
                                color: Color.fromRGBO(171, 171, 171, 1.0),
                                fontSize: 18),
                            ),
              ],
            )
          )
    )));
  }
}
