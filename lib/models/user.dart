class User {
  String id;
  String userName;
  String passwordHash;
  List<FavoriteList> favoriteLists;

  User({
    required this.id,
    required this.userName,
    required this.passwordHash,
    required this.favoriteLists,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      userName: json['userName'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      favoriteLists: json['favoriteLists'] != null
          ? (json['favoriteLists'] as List)
              .map((e) => FavoriteList.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userName': userName,
      'passwordHash': passwordHash,
      'favoriteLists': favoriteLists.map((e) => e.toJson()).toList(),
    };
  }
}

class FavoriteList {
  String listId;

  FavoriteList({required this.listId});

  factory FavoriteList.fromJson(Map<String, dynamic> json) {
    return FavoriteList(
      listId: json['listId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listId': listId,
    };
  }
}
