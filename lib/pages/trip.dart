import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:my_first_app/model/response/trip_idx_get.dart';

class TripPage extends StatefulWidget {
  int idx = 0;
  TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  String url = '';
  // Create late variables
  late TripGetResponse tripIdxGetResponse;
  late Future<void> loadData; 

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียดทริป")),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อทริป
                Text(
                  tripIdxGetResponse.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // ประเทศ
                Text(
                  tripIdxGetResponse.country,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // รูป
                Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: tripIdxGetResponse.coverimage.isNotEmpty
                          ? Image.network(
                              tripIdxGetResponse.coverimage,
                              width: 300,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 300,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),


                const SizedBox(height: 12),

                // ราคา
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ราคา ${tripIdxGetResponse.price} บาท",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "โซน${tripIdxGetResponse.destinationZone}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // รายละเอียด
                Text(
                  tripIdxGetResponse.detail,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),

                const SizedBox(height: 24),

                // ปุ่มจอง
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: เพิ่ม action ตอนกดปุ่ม
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("คุณกดจองแล้ว!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      "จองเลย!!!",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

   void initState() {
    super.initState();
    // Call async function
    loadData = loadDataAsync();
  }
  
  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/trips/${widget.idx}'));
    log(res.body);
    tripIdxGetResponse = tripGetResponseFromJson(res.body);
  }

  }
