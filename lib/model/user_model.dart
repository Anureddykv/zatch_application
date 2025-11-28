class ProfilePic {
  final String? publicId;
  final String? url;

  ProfilePic({this.publicId, this.url});

  factory ProfilePic.fromJson(Map<String, dynamic> json) {
    return ProfilePic(
      publicId: json['public_id'] as String?,
      url: json['url'] as String?,
    );
  }

  static ProfilePic fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) {
      return ProfilePic(publicId: '', url: '');
    }
    return ProfilePic.fromJson(json);
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  Address({this.street, this.city, this.state, this.pincode, this.country});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String?,
    );
  }

  static Address? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Address.fromJson(json);
  }
}

class UserFollowerInfo {
  final ProfilePic profilePic;
  final String id;
  final String? username;

  UserFollowerInfo({required this.profilePic, required this.id, this.username});

  factory UserFollowerInfo.fromJson(Map<String, dynamic> json) {
    return UserFollowerInfo(
      profilePic: ProfilePic.fromJsonOrNull(
        json['profilePic'] as Map<String, dynamic>?,
      ),
      id: json['_id'] as String,
      username: json['username'] as String?,
    );
  }
}

class UserModel {
  final ProfilePic profilePic;
  final String id;
  final String displayName;
  final String? username;
  final String? name;
  final String? phone;
  final String? email;
  final String? role;
  final String? gender;
  final String? categoryType;
  final List<UserFollowerInfo> followers;
  final List<UserFollowerInfo> following;
  int followerCount;
  final int reviewsCount;
  final int productsSoldCount;
  final num customerRating;
  final List<String> savedBits;
  final List<String> savedProducts;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profileImageUrl;
  final String? dateOfBirth;
  final String? shopName;
  final String? shopDescription;
  final bool? kycVerified;
  final Address? address;
  bool isFollowing;

  UserModel({
    required this.profilePic,
    required this.id,
    required this.displayName,
    this.username,
    this.name,
    this.phone,
    this.email,
    this.role,
    this.gender,
    this.categoryType,
    required this.followers,
    required this.following,
    required this.followerCount,
    required this.reviewsCount,
    required this.productsSoldCount,
    required this.customerRating,
    required this.savedBits,
    required this.savedProducts,
    required this.isAdmin,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
    this.dateOfBirth,
    this.shopName,
    this.shopDescription,
    this.kycVerified,
    this.address,
    this.isFollowing = false,
  });

  // ✅ Add this copyWith method
  UserModel copyWith({
    ProfilePic? profilePic,
    String? id,
    String? displayName,
    String? username,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? gender,
    String? categoryType,
    List<UserFollowerInfo>? followers,
    List<UserFollowerInfo>? following,
    int? followerCount,
    int? reviewsCount,
    int? productsSoldCount,
    num? customerRating,
    List<String>? savedBits,
    List<String>? savedProducts,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    String? dateOfBirth,
    String? shopName,
    String? shopDescription,
    bool? kycVerified,
    Address? address,
    bool? isFollowing,
  }) {
    return UserModel(
      profilePic: profilePic ?? this.profilePic,
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      categoryType: categoryType ?? this.categoryType,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followerCount: followerCount ?? this.followerCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      productsSoldCount: productsSoldCount ?? this.productsSoldCount,
      customerRating: customerRating ?? this.customerRating,
      savedBits: savedBits ?? this.savedBits,
      savedProducts: savedProducts ?? this.savedProducts,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      kycVerified: kycVerified ?? this.kycVerified,
      address: address ?? this.address,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String displayName;
    if (json['username'] != null && (json['username'] as String).isNotEmpty) {
      displayName = json['username'] as String;
    } else if (json['name'] != null && (json['name'] as String).isNotEmpty) {
      displayName = json['name'] as String;
    } else {
      displayName = 'User';
    }

    var followersList =
        (json['followers'] as List<dynamic>?)
            ?.map((i) => UserFollowerInfo.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    var followingList =
        (json['following'] as List<dynamic>?)
            ?.map((i) => UserFollowerInfo.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    var savedBitsList =
        (json['savedBits'] as List<dynamic>?)
            ?.map((i) => i as String)
            .toList() ??
        [];
    var savedProductsList =
        (json['savedProducts'] as List<dynamic>?)
            ?.map((i) => i as String)
            .toList() ??
        [];

    final createdAtString = json['createdAt'] as String?;

    return UserModel(
      profilePic: ProfilePic.fromJsonOrNull(
        json['profilePic'] as Map<String, dynamic>?,
      ),
      id: json['_id'] as String? ?? '', // Also made the ID parsing safer
      displayName: displayName,
      username: json['username'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      categoryType: json['categoryType'] as String?,
      followers: followersList,
      following: followingList,
      followerCount: json['followerCount'] as int? ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      productsSoldCount: json['productsSoldCount'] as int? ?? 0,
      customerRating: json['customerRating'] as num? ?? 0,
      savedBits: savedBitsList,
      savedProducts: savedProductsList,
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt:
          createdAtString != null
              ? DateTime.parse(createdAtString)
              : DateTime.now(),

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      profileImageUrl: json['profileImageUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      shopName: json['shopName'] as String?,
      shopDescription: json['shopDescription'] as String?,
      kycVerified: json['kycVerified'] as bool?,
      address: Address.fromJsonOrNull(json['address'] as Map<String, dynamic>?),
      isFollowing: json['isFollowing'] == true,
    );
  }
}
