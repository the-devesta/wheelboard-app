import 'dart:io';

class ProfessionalSignupmodel {
  final String? email;
  final String? password;
  final String? fullName;
  final String? fatherName;
  final String? dob;
  final String? mobileNo;
  final String? professionalType;
  final String? state;
  final String? city;
  final File? driverImage;

  ProfessionalSignupmodel({
    this.email,
    this.password,
    this.fullName,
    this.fatherName,
    this.mobileNo,
    this.dob,
    this.professionalType,
    this.state,
    this.city,
    this.driverImage,
  });

  // Convert to normal string fields (without file)
  Map<String, String?> toJsonFields() {
    final map = {
      "Email": email,
      "Password": password,
      "Name": fullName,
      "FatherName": fatherName,
      "DateOfBirth": dob,
      "MobileNo": mobileNo,
      "State": state,
      "City": city,
      "ProfessionalType": professionalType,
    };

    return map;
  }
}
