import 'dart:convert';

List<ExpensePurpose> expensePurposeFromJson(String str) =>
    List<ExpensePurpose>.from(json.decode(str).map((x) => ExpensePurpose.fromJson(x)));

String expensePurposeToJson(List<ExpensePurpose> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpensePurpose {
  final int expensePurposeId;
  final String purposeName;

  ExpensePurpose({
    required this.expensePurposeId,
    required this.purposeName,
  });

  factory ExpensePurpose.fromJson(Map<String, dynamic> json) => ExpensePurpose(
        expensePurposeId: json["expensePurposeId"],
        purposeName: json["purposeName"],
      );

  Map<String, dynamic> toJson() => {
        "expensePurposeId": expensePurposeId,
        "purposeName": purposeName,
      };
}

