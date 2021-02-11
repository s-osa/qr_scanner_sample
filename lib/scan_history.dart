import 'dart:convert';

ScanHistory scanHistoryFromJson(String str) {
  final jsonData = json.decode(str);
  return ScanHistory.fromMap(jsonData);
}

String scanHistoryToJson(ScanHistory data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class ScanHistory {
  int id;
  String payload;

  ScanHistory({
    this.id,
    this.payload,
  });


  factory ScanHistory.fromMap(Map<String, dynamic> json) => new ScanHistory(
    id: json["id"],
    payload: json["payload"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "payload": payload,
  };
}
