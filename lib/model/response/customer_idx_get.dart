// To parse this JSON data, do
//
//     final tripGetResponse = tripGetResponseFromJson(jsonString);

import 'dart:convert';

TripGetResponse tripGetResponseFromJson(String str) => TripGetResponse.fromJson(json.decode(str));

String tripGetResponseToJson(TripGetResponse data) => json.encode(data.toJson());

class TripGetResponse {
    int idx;
    String fullname;
    String phone;
    String email;
    String image;

    TripGetResponse({
        required this.idx,
        required this.fullname,
        required this.phone,
        required this.email,
        required this.image,
    });

    factory TripGetResponse.fromJson(Map<String, dynamic> json) => TripGetResponse(
        idx: json["idx"],
        fullname: json["fullname"],
        phone: json["phone"],
        email: json["email"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "idx": idx,
        "fullname": fullname,
        "phone": phone,
        "email": email,
        "image": image,
    };
}
