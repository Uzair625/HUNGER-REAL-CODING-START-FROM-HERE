class UserModel {
  final String uid, name, phone, email, authMode, dob, address, photoUrl;
  final bool isGuest;

  UserModel({
    required this.uid,
    this.name = '', this.phone = '', this.email = '',
    this.authMode = 'phone', this.dob = '', this.address = '',
    this.isGuest = false, this.photoUrl = '',
  });

  Map<String, dynamic> toMap() => {
    'uid': uid, 'name': name, 'phone': phone, 'email': email,
    'authMode': authMode, 'dob': dob, 'address': address,
    'isGuest': isGuest, 'photoUrl': photoUrl,
  };

  factory UserModel.fromMap(Map<String, dynamic> d) => UserModel(
    uid: d['uid'] ?? '', name: d['name'] ?? '', phone: d['phone'] ?? '',
    email: d['email'] ?? '', authMode: d['authMode'] ?? 'phone',
    dob: d['dob'] ?? '', address: d['address'] ?? '',
    isGuest: d['isGuest'] ?? false, photoUrl: d['photoUrl'] ?? '',
  );

  UserModel copyWith({
    String? name, String? email, String? dob,
    String? phone, String? address, String? photoUrl,
  }) => UserModel(
    uid: uid, name: name ?? this.name, phone: phone ?? this.phone,
    email: email ?? this.email, authMode: authMode, dob: dob ?? this.dob,
    address: address ?? this.address, isGuest: isGuest,
    photoUrl: photoUrl ?? this.photoUrl,
  );
}