import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/model/request/customers_login_post_req.dart';
import 'package:my_first_app/model/response/customers_login_post_res.dart';
import 'package:my_first_app/pages/register.dart';
import 'package:my_first_app/pages/showtrip.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = '';
  int number = 0;
  String url = '';
  String errorMessage = 'This is my text';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  var phoneCtl = TextEditingController();
  var passCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login page')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  login('Image', '1234');
                },
                child: Image.asset('assets/images/bg.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text('หมายเลขโทรศัพท์')],
                          ),
                          TextField(
                            controller: phoneCtl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text('รหัสผ่าน')],
                          ),
                          TextField(
                            controller: passCtl,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      register();
                    },
                    child: const Text('ลงทะเบียนใหม่'),
                  ),
                  FilledButton(
                    onPressed: () {
                      login('0817399999', '1111');
                    },
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(text, style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void login(String username, String password) {
    // var data = {"phone": "0817399999", "password": "1111"};

    CustomerLoginPostRequest request = CustomerLoginPostRequest(
      phone: phoneCtl.text,
      password: passCtl.text,
      
    );
    http
        .post(
          Uri.parse("$url/customers/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(request),
        )
        .then((value) {
          CustomerLoginPostResponse customerLoginPostResponse =
            customerLoginPostResponseFromJson(value.body);
          log(customerLoginPostResponse.customer.fullname);
          log(customerLoginPostResponse.customer.email);
          Navigator.push(
           context,
            MaterialPageRoute(
              builder: (context) => ShowTripPage(cid: customerLoginPostResponse.customer.idx,),
            ));
        })
        .catchError((error) {
          // log('Error $error');
        });

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ShowTripPage()),
    // );

    // log(phoneCtl.text);
  }

  void register() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
     errorMessage = 'ลงทะเบียน';
    });
  }
}
