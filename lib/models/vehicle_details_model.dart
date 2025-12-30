class VehicleDetailsModel {
  final String regNo;
  final String chassis;
  final String engine;
  final String vehicleManufacturerName;
  final String model;
  final String vehicleColour;
  final String type;
  final String normsType;
  final String bodyType;
  final String ownerCount;
  final String owner;
  final String ownerFatherName;
  final String mobileNumber;
  final String status;
  final String statusAsOn;
  final String regAuthority;
  final String regDate;
  final String vehicleManufacturingMonthYear;
  final String rcExpiryDate;
  final String vehicleTaxUpto;
  final String vehicleInsuranceCompanyName;
  final String vehicleInsuranceUpto;
  final String vehicleInsurancePolicyNumber;
  final String rcFinancer;
  final String presentAddress;
  final String permanentAddress;
  final String vehicleCubicCapacity;
  final String grossVehicleWeight;
  final String unladenWeight;
  final String vehicleCategory;
  final String rcStandardCap;
  final String vehicleCylindersNo;
  final String vehicleSeatCapacity;
  final String vehicleSleeperCapacity;
  final String vehicleStandingCapacity;
  final String wheelbase;
  final String vehicleNumber;
  final String puccNumber;
  final String puccUpto;
  final bool blacklistStatus;
  final List<dynamic> blacklistDetails;
  final String permitIssueDate;
  final String permitNumber;
  final String permitType;
  final String permitValidFrom;
  final String permitValidUpto;
  final bool isCommercial;
  final String nocDetails;
  final bool dbResult;
  final bool partialData;
  final String vehicleClass;

  VehicleDetailsModel({
    required this.regNo,
    required this.chassis,
    required this.engine,
    required this.vehicleManufacturerName,
    required this.model,
    required this.vehicleColour,
    required this.type,
    required this.normsType,
    required this.bodyType,
    required this.ownerCount,
    required this.owner,
    required this.ownerFatherName,
    required this.mobileNumber,
    required this.status,
    required this.statusAsOn,
    required this.regAuthority,
    required this.regDate,
    required this.vehicleManufacturingMonthYear,
    required this.rcExpiryDate,
    required this.vehicleTaxUpto,
    required this.vehicleInsuranceCompanyName,
    required this.vehicleInsuranceUpto,
    required this.vehicleInsurancePolicyNumber,
    required this.rcFinancer,
    required this.presentAddress,
    required this.permanentAddress,
    required this.vehicleCubicCapacity,
    required this.grossVehicleWeight,
    required this.unladenWeight,
    required this.vehicleCategory,
    required this.rcStandardCap,
    required this.vehicleCylindersNo,
    required this.vehicleSeatCapacity,
    required this.vehicleSleeperCapacity,
    required this.vehicleStandingCapacity,
    required this.wheelbase,
    required this.vehicleNumber,
    required this.puccNumber,
    required this.puccUpto,
    required this.blacklistStatus,
    required this.blacklistDetails,
    required this.permitIssueDate,
    required this.permitNumber,
    required this.permitType,
    required this.permitValidFrom,
    required this.permitValidUpto,
    required this.isCommercial,
    required this.nocDetails,
    required this.dbResult,
    required this.partialData,
    required this.vehicleClass,
  });

  factory VehicleDetailsModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle the correct API response structure
    final result = json['result'];
    if (result == null) {
      throw Exception('Result field is null in API response');
    }

    final data = result['data'];
    if (data == null) {
      throw Exception('Data field is null in API response');
    }

    return VehicleDetailsModel(
      regNo: data['regNo'] ?? '',
      chassis: data['chassis'] ?? '',
      engine: data['engine'] ?? '',
      vehicleManufacturerName: data['vehicleManufacturerName'] ?? '',
      model: data['model'] ?? '',
      vehicleColour: data['vehicleColour'] ?? '',
      type: data['type'] ?? '',
      normsType: data['normsType'] ?? '',
      bodyType: data['bodyType'] ?? '',
      ownerCount: data['ownerCount'] ?? '',
      owner: data['owner'] ?? '',
      ownerFatherName: data['ownerFatherName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      status: data['status'] ?? '',
      statusAsOn: data['statusAsOn'] ?? '',
      regAuthority: data['regAuthority'] ?? '',
      regDate: data['regDate'] ?? '',
      vehicleManufacturingMonthYear:
          data['vehicleManufacturingMonthYear'] ?? '',
      rcExpiryDate: data['rcExpiryDate'] ?? '',
      vehicleTaxUpto: data['vehicleTaxUpto'] ?? '',
      vehicleInsuranceCompanyName: data['vehicleInsuranceCompanyName'] ?? '',
      vehicleInsuranceUpto: data['vehicleInsuranceUpto'] ?? '',
      vehicleInsurancePolicyNumber: data['vehicleInsurancePolicyNumber'] ?? '',
      rcFinancer: data['rcFinancer'] ?? '',
      presentAddress: data['presentAddress'] ?? '',
      permanentAddress: data['permanentAddress'] ?? '',
      vehicleCubicCapacity: data['vehicleCubicCapacity'] ?? '',
      grossVehicleWeight: data['grossVehicleWeight'] ?? '',
      unladenWeight: data['unladenWeight'] ?? '',
      vehicleCategory: data['vehicleCategory'] ?? '',
      rcStandardCap: data['rcStandardCap'] ?? '',
      vehicleCylindersNo: data['vehicleCylindersNo'] ?? '',
      vehicleSeatCapacity: data['vehicleSeatCapacity'] ?? '',
      vehicleSleeperCapacity: data['vehicleSleeperCapacity'] ?? '',
      vehicleStandingCapacity: data['vehicleStandingCapacity'] ?? '',
      wheelbase: data['wheelbase'] ?? '',
      vehicleNumber: data['vehicleNumber'] ?? '',
      puccNumber: data['puccNumber'] ?? '',
      puccUpto: data['puccUpto'] ?? '',
      blacklistStatus: data['blacklistStatus'] ?? false,
      blacklistDetails: data['blacklistDetails'] ?? [],
      permitIssueDate: data['permitIssueDate'] ?? '',
      permitNumber: data['permitNumber'] ?? '',
      permitType: data['permitType'] ?? '',
      permitValidFrom: data['permitValidFrom'] ?? '',
      permitValidUpto: data['permitValidUpto'] ?? '',
      isCommercial: data['isCommercial'] ?? false,
      nocDetails: data['nocDetails'] ?? '',
      dbResult: data['dbResult'] ?? false,
      partialData: data['partialData'] ?? false,
      vehicleClass: data['class'] ?? '',
    );
  }
}
