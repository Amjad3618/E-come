class UserModel {
  String uid;  // Add the uid field here
  String name;
  String email;
  String password;
  String confirmpassword;

  UserModel({
    required this.uid, 
    required this.name, 
    required this.email, 
    required this.password,
    required this.confirmpassword
  });

  // Method to convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,  // Store the uid in Firestore
      'name': name,
      'email': email,
      'password': password,
      'confirmpassword': confirmpassword
    };
  }

  // Method to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],  // Fetch the uid from Firestore document
      name: json['name'],
      email: json['email'],
      password: json['password'],
      confirmpassword: json['confirmpassword'],
    );
  }
}
