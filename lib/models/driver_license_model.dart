class DriverLicenseModel {
  final String dlNumber;
  final String dob;
  final List<BadgeDetail> badgeDetails;
  final DlValidity dlValidity;
  final DetailsOfDrivingLicence detailsOfDrivingLicence;

  DriverLicenseModel({
    required this.dlNumber,
    required this.dob,
    required this.badgeDetails,
    required this.dlValidity,
    required this.detailsOfDrivingLicence,
  });

  factory DriverLicenseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return DriverLicenseModel(
      dlNumber: result['dlNumber'] ?? '',
      dob: result['dob'] ?? '',
      badgeDetails:
          (result['badgeDetails'] as List?)
              ?.map((e) => BadgeDetail.fromJson(e))
              .toList() ??
          [],
      dlValidity: DlValidity.fromJson(result['dlValidity'] ?? {}),
      detailsOfDrivingLicence: DetailsOfDrivingLicence.fromJson(
        result['detailsOfDrivingLicence'] ?? {},
      ),
    );
  }
}

class BadgeDetail {
  final String badgeIssueDate;
  final String badgeNo;
  final List<String> classOfVehicle;

  BadgeDetail({
    required this.badgeIssueDate,
    required this.badgeNo,
    required this.classOfVehicle,
  });

  factory BadgeDetail.fromJson(Map<String, dynamic> json) {
    return BadgeDetail(
      badgeIssueDate: json['badgeIssueDate'] ?? '',
      badgeNo: json['badgeNo'] ?? '',
      classOfVehicle:
          (json['classOfVehicle'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DlValidity {
  final ValidityPeriod nonTransport;
  final ValidityPeriod transport;
  final String hazardousValidTill;
  final String hillValidTill;

  DlValidity({
    required this.nonTransport,
    required this.transport,
    required this.hazardousValidTill,
    required this.hillValidTill,
  });

  factory DlValidity.fromJson(Map<String, dynamic> json) {
    return DlValidity(
      nonTransport: ValidityPeriod.fromJson(json['nonTransport'] ?? {}),
      transport: ValidityPeriod.fromJson(json['transport'] ?? {}),
      hazardousValidTill: json['hazardousValidTill'] ?? '',
      hillValidTill: json['hillValidTill'] ?? '',
    );
  }
}

class ValidityPeriod {
  final String from;
  final String to;

  ValidityPeriod({required this.from, required this.to});

  factory ValidityPeriod.fromJson(Map<String, dynamic> json) {
    return ValidityPeriod(from: json['from'] ?? '', to: json['to'] ?? '');
  }
}

class DetailsOfDrivingLicence {
  final String dateOfIssue;
  final String dateOfLastTransaction;
  final String status;
  final String lastTransactedAt;
  final String name;
  final String fatherOrHusbandName;
  final List<AddressList> addressList;
  final String address;
  final String photo;
  final SplitAddress splitAddress;
  final List<dynamic> covDetails;

  DetailsOfDrivingLicence({
    required this.dateOfIssue,
    required this.dateOfLastTransaction,
    required this.status,
    required this.lastTransactedAt,
    required this.name,
    required this.fatherOrHusbandName,
    required this.addressList,
    required this.address,
    required this.photo,
    required this.splitAddress,
    required this.covDetails,
  });

  factory DetailsOfDrivingLicence.fromJson(Map<String, dynamic> json) {
    return DetailsOfDrivingLicence(
      dateOfIssue: json['dateOfIssue'] ?? '',
      dateOfLastTransaction: json['dateOfLastTransaction'] ?? '',
      status: json['status'] ?? '',
      lastTransactedAt: json['lastTransactedAt'] ?? '',
      name: json['name'] ?? '',
      fatherOrHusbandName: json['fatherOrHusbandName'] ?? '',
      addressList:
          (json['addressList'] as List?)
              ?.map((e) => AddressList.fromJson(e))
              .toList() ??
          [],
      address: json['address'] ?? '',
      photo: json['photo'] ?? '',
      splitAddress: SplitAddress.fromJson(json['splitAddress'] ?? {}),
      covDetails: json['covDetails'] ?? [],
    );
  }
}

class AddressList {
  final String completeAddress;
  final String type;
  final SplitAddress splitAddress;

  AddressList({
    required this.completeAddress,
    required this.type,
    required this.splitAddress,
  });

  factory AddressList.fromJson(Map<String, dynamic> json) {
    return AddressList(
      completeAddress: json['completeAddress'] ?? '',
      type: json['type'] ?? '',
      splitAddress: SplitAddress.fromJson(json['splitAddress'] ?? {}),
    );
  }
}

class SplitAddress {
  final List<String> district;
  final List<List<String>> state;
  final List<String> city;
  final String pincode;
  final List<String> country;
  final String addressLine;

  SplitAddress({
    required this.district,
    required this.state,
    required this.city,
    required this.pincode,
    required this.country,
    required this.addressLine,
  });

  factory SplitAddress.fromJson(Map<String, dynamic> json) {
    return SplitAddress(
      district:
          (json['district'] as List?)?.map((e) => e.toString()).toList() ?? [],
      state:
          (json['state'] as List?)
              ?.map((e) => (e as List).map((item) => item.toString()).toList())
              .toList() ??
          [],
      city: (json['city'] as List?)?.map((e) => e.toString()).toList() ?? [],
      pincode: json['pincode'] ?? '',
      country:
          (json['country'] as List?)?.map((e) => e.toString()).toList() ?? [],
      addressLine: json['addressLine'] ?? '',
    );
  }
}
