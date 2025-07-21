class CompanySignUpModel {
  final String companyName;
  final String mobileNo;
  final String email;
  final String password;
  final String businessCategory;

  CompanySignUpModel({
    required this.companyName,
    required this.mobileNo,
    required this.email,
    required this.password,
    required this.businessCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      "companyName": companyName,
      "mobileNo": mobileNo,
      "email": email,
      "password": password,
      "businessCategory": businessCategory,
    };
  }
}
