import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/model/response/customer_idx_get.dart';
class ProfilePage extends StatefulWidget {
  int idx = 0;
  ProfilePage({super.key, required this.idx});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<void> loaddata;
  late TripGetResponse customerIdxGetResponse;
  var fullnameCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var emailCtl = TextEditingController();
  var imageCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loaddata = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    log('Customer id: ${widget.idx}');
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลส่วนตัว'),
       actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'ยืนยันการยกเลิกสมาชิก?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('ปิด'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context); // ปิด dialog ก่อน
                              delete(); // เรียกฟังก์ชันลบ
                            },
                            child: const Text('ยืนยัน'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ยกเลิกสมาชิก'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loaddata,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                // เปลี่ยนจาก Image.network(customerIdxGetResponse.image) เป็น
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: customerIdxGetResponse.image.isNotEmpty
                        ? Image.network(
                            customerIdxGetResponse.image,
                            width: 170,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: fullnameCtl,
                    decoration: const InputDecoration(
                      labelText: "ชื่อ-นามสกุล",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    controller: phoneCtl,
                    decoration: InputDecoration(labelText: 'หมายเลขโทรศัพท์'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    controller: emailCtl,
                    decoration: InputDecoration(labelText: 'อีเมล์'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    controller: imageCtl,
                    decoration: InputDecoration(labelText: 'รูปภาพ'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FilledButton(
                    onPressed: UpdateData,
                    child: Text("บันทึกข้อมูล"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void UpdateData() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var json = {
      "fullname": fullnameCtl.text,
      "phone": phoneCtl.text,
      "email": emailCtl.text,
      "image": imageCtl.text,
    };
    log(json.toString());
    var res = await http.put(
      Uri.parse('$url/customers/${widget.idx}'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode(json),
    );
    log(res.body);
    var result = jsonDecode(res.body);
    //Encode Map => JSON Sring
    //Decode JSON String => MAp
    log(result['message']);
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('สำเร็จ'),
        content: const Text('บันทึกข้อมูลเรียบร้อย'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/customers/${widget.idx}'));
    log(res.body);
    customerIdxGetResponse = tripGetResponseFromJson(res.body);
    fullnameCtl.text = customerIdxGetResponse.fullname;
    phoneCtl.text = customerIdxGetResponse.phone;
    emailCtl.text = customerIdxGetResponse.email;
    imageCtl.text = customerIdxGetResponse.image;
  }

  void delete() async {
    try {
      var config = await Configuration.getConfig();
      var url = config['apiEndpoint'];

      var res = await http.delete(Uri.parse('$url/customers/${widget.idx}'));
      log(res.statusCode.toString());

      if (res.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: const Text('ลบข้อมูลสำเร็จ'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('ปิด'),
              ),
            ],
          ),
        ).then((s) {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ผิดพลาด'),
            content: const Text('ลบข้อมูลไม่สำเร็จ'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      log("Error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ผิดพลาด'),
          content: Text('เกิดข้อผิดพลาด: $e'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }
}
