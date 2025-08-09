// To parse this JSON data, do
//
//     final skuModel = skuModelFromJson(jsonString);

import 'dart:convert';

List<SkuModel> skuModelFromJson(String str) => List<SkuModel>.from(json.decode(str).map((x) => SkuModel.fromJson(x)));

String skuModelToJson(List<SkuModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SkuModel {
  String title;
  String renewMessage;
  String price;
  String sku;

  SkuModel({
    required this.title,
    required this.price,
    required this.renewMessage,
    required this.sku,
  });

  factory SkuModel.fromJson(Map<String, dynamic> json) => SkuModel(
    title: json["title"],
    price: json["price"],
    renewMessage: json["renew_message"],
    sku: json["sku"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "price": price,
    "renew_message": renewMessage,
    "sku": sku,
  };
}
