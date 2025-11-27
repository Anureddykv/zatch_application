class Follower {
  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final bool isFollowing;

  Follower(
      this.name,
      this.category,
      this.imageAsset, {
        this.id = "",
        this.isFollowing = false,
      });

  Follower copyWith({
    String? id,
    String? name,
    String? category,
    String? imageAsset,
    bool? isFollowing,
  }) {
    return Follower(
      name ?? this.name,
      category ?? this.category,
      imageAsset ?? this.imageAsset,
      id: id ?? this.id,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
