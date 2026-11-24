class Influencer {
  final String id;
  final String name;
  final int age;
  final String address;
  final String city;
  final String state;
  final String contactPrimary;
  final String contactSecondary;
  final String emailPersonal;
  final String emailWork;
  final Map<String, String> socialLinks; // {ig, x, snap, yt, tg}
  final List<String> collabs;
  final String category;
  final double pricePerReel;
  final List<String> portfolioImages;
  final String membershipTier; // "free", "gold", "burgundy"
  final DateTime? membershipExpiry;
  final int impressionsCount;
  final int viewsCount;
  final double rating;
  final String followersCount;
  final String bio;

  const Influencer({
    required this.id,
    required this.name,
    required this.age,
    required this.address,
    required this.city,
    required this.state,
    required this.contactPrimary,
    required this.contactSecondary,
    required this.emailPersonal,
    required this.emailWork,
    required this.socialLinks,
    required this.collabs,
    required this.category,
    required this.pricePerReel,
    required this.portfolioImages,
    this.membershipTier = "free",
    this.membershipExpiry,
    this.impressionsCount = 0,
    this.viewsCount = 0,
    this.rating = 4.9,
    this.followersCount = "45K",
    this.bio = "Creating captivating digital stories and driving authentic regional engagement.",
  });

  bool get isGold => membershipTier == "gold";
  bool get isBurgundy => membershipTier == "burgundy";
  bool get isPremium => isGold || isBurgundy;

  Influencer copyWith({
    String? id,
    String? name,
    int? age,
    String? address,
    String? city,
    String? state,
    String? contactPrimary,
    String? contactSecondary,
    String? emailPersonal,
    String? emailWork,
    Map<String, String>? socialLinks,
    List<String>? collabs,
    String? category,
    double? pricePerReel,
    List<String>? portfolioImages,
    String? membershipTier,
    DateTime? membershipExpiry,
    int? impressionsCount,
    int? viewsCount,
    double? rating,
    String? followersCount,
    String? bio,
  }) {
    return Influencer(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      contactPrimary: contactPrimary ?? this.contactPrimary,
      contactSecondary: contactSecondary ?? this.contactSecondary,
      emailPersonal: emailPersonal ?? this.emailPersonal,
      emailWork: emailWork ?? this.emailWork,
      socialLinks: socialLinks ?? this.socialLinks,
      collabs: collabs ?? this.collabs,
      category: category ?? this.category,
      pricePerReel: pricePerReel ?? this.pricePerReel,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      membershipTier: membershipTier ?? this.membershipTier,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      impressionsCount: impressionsCount ?? this.impressionsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      rating: rating ?? this.rating,
      followersCount: followersCount ?? this.followersCount,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'age': age.toString(),
      'address': '$address, $city, $state',
      'contact_primary': contactPrimary,
      'contact_secondary': contactSecondary,
      'email_personal': emailPersonal,
      'email_work': emailWork,
      'social_links': socialLinks,
      'collabs': collabs,
      'category': category,
      'price_per_reel': pricePerReel,
      'portfolio_images': portfolioImages,
      'membership_tier': membershipTier,
      'membership_expiry': membershipExpiry?.toIso8601String(),
    };
  }
}
