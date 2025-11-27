class SearchResult {
  bool success;
  String message;
  List<Products> products;
  List<Person> people;
  List<Person> all;

  SearchResult({
    required this.success,
    required this.message,
    required this.products,
    required this.people,
    required this.all,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Debug: print raw JSON
    print("Raw SearchResult JSON: $json");

    return SearchResult(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      products: json['products'] != null
          ? List<Products>.from(
          json['products'].map((x) => Products.fromJson(x)))
          : [],
      people: json['people'] != null
          ? List<Person>.from(json['people'].map((x) => Person.fromJson(x)))
          : [],
      all: json['all'] != null
          ? List<Person>.from(json['all'].map((x) => Person.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'products': List<dynamic>.from(products.map((x) => x.toJson())),
    'people': List<dynamic>.from(people.map((x) => x.toJson())),
    'all': List<dynamic>.from(all.map((x) => x.toJson())),
  };
}

class Products {
  String id;
  String title;
  String price;
  String image;

  Products({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    price: json['price']?.toString() ?? '',
    image: json['image'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'price': price,
    'image': image,
  };
}


class Person {
  ProfilePic profilePic;
  String id;
  String username;
  String? email;
  int followerCount;

  Person({
    required this.profilePic,
    required this.id,
    required this.username,
    this.email,
    required this.followerCount,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    // Debug: print each person JSON
    print("Raw Person JSON: $json");

    return Person(
      profilePic: json['profilePic'] != null
          ? ProfilePic.fromJson(json['profilePic'])
          : ProfilePic(publicId: "", url: ""),
      id: json['_id'] ?? "",
      username: json['username'] ?? "",
      email: json['email'],
      followerCount: json['followerCount'] != null
          ? (json['followerCount'] is int
          ? json['followerCount']
          : int.tryParse(json['followerCount'].toString()) ?? 0)
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'profilePic': profilePic.toJson(),
    '_id': id,
    'username': username,
    if (email != null) 'email': email,
    'followerCount': followerCount,
  };
}

class ProfilePic {
  String publicId;
  String url;

  ProfilePic({
    required this.publicId,
    required this.url,
  });

  factory ProfilePic.fromJson(Map<String, dynamic> json) {
    // Debug: print profilePic JSON
    print("Raw ProfilePic JSON: $json");

    return ProfilePic(
      publicId: json['public_id'] ?? "",
      url: json['url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'public_id': publicId,
    'url': url,
  };
}
