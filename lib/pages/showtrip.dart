import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/model/response/trips_get_res.dart';
import 'package:my_first_app/pages/trip.dart';
import 'package:my_first_app/pages/profile.dart';

class ShowTripPage extends StatefulWidget {
  final int cid;
  ShowTripPage({super.key, required this.cid});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String url = '';
  List<TripGetResponse> allTrips = []; // เก็บ trips ทั้งหมด
  List<TripGetResponse> tripGetResponses = []; // ใช้แสดงผลหลัง filter
  late Future<void> loadData;
   List<String> aseanCountries = [
  'ประเทศไทย',
  'เวียดนาม',
  'สิงคโปร์',
  'มาเลเซีย',
  'อินโดนีเซีย',
  'ฟิลิปปินส์',
  'ลาว',
  'พม่า',
  'กัมพูชา',
  'บรูไน',
];

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var res = await http.get(Uri.parse('$url/trips'));
    log(res.body);

    setState(() {
      allTrips = tripGetResponseFromJson(res.body);
      tripGetResponses = allTrips; // ค่าเริ่มต้นคือทั้งหมด
    });

    log(allTrips.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Trip'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(idx: widget.cid),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(children: [Text('ปลายทาง')]),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          FilledButton(onPressed: getTrips, child: Text('ทั้งหมด')),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => getZoneTrips('เอเชีย'),
                            child: Text('เอเชีย'),
                          ),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => getZoneTrips('ยุโรป'),
                            child: Text('ยุโรป'),
                          ),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => getZoneTrips('อาเซียน'),
                            child: Text('อาเซียน'),
                          ), FilledButton(
                            onPressed: () => getZoneTrips('ประเทศไทย'),
                            child: Text('ไทย'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: tripGetResponses
                          .map(
                            (trip) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          trip.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                            Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 150,
                                                  child: trip.coverimage.isNotEmpty
                                                      ? Image.network(
                                                          trip.coverimage,
                                                          width: 150,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const Icon(
                                                              Icons.image_not_supported,
                                                              size: 100,
                                                              color: Colors.grey,
                                                            );
                                                          }
                                                        )
                                                      : const Text("..."),
                                                ),
                                             ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(trip.country),
                                              Text('ระยะเวลา ${trip.duration} วัน'),
                                              Text('ราคา ${trip.price} บาท'),
                                              FilledButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripPage(idx: trip.idx),
                                                    ),
                                                  );
                                                },
                                                child: const Text('รายละเอียดเพิ่มเติม'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

void getZoneTrips(String zone) {
  if (zone == 'อาเซียน') {
    setState(() {
      tripGetResponses = allTrips
          .where((trip) => aseanCountries.contains(trip.country))
          .toList();
    });
  } else {
    // กรองแบบทั่วไปสำหรับโซนอื่น ๆ
    setState(() {
      tripGetResponses = allTrips
          .where((trip) => trip.destinationZone.toLowerCase().contains(zone.toLowerCase()))
          .toList();
    });
  }
}
  Future<void> getTrips() async {
    setState(() {
      tripGetResponses = allTrips; // reset เป็นทั้งหมด
    });
    log(tripGetResponses.length.toString());
  }
}
