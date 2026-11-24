class ProfileView {
  final String id;
  final String influencerId;
  final String brandId;
  final String brandName;
  final String brandEmail;
  final String brandCategory;
  final String brandLocation; // e.g. "Koregaon Park, Pune"
  final DateTime createdAt;
  final bool notifiedViaEmail;
  final String brandPhone;
  final String brandArea;
  final bool isDirectConnect;
  final bool isUnlockedByCreator;

  const ProfileView({
    required this.id,
    required this.influencerId,
    required this.brandId,
    required this.brandName,
    required this.brandEmail,
    required this.brandCategory,
    required this.brandLocation,
    required this.createdAt,
    this.notifiedViaEmail = true,
    this.brandPhone = "+91 98220 81132",
    this.brandArea = "Koregaon Park",
    this.isDirectConnect = false,
    this.isUnlockedByCreator = false,
  });

  ProfileView copyWith({
    String? id,
    String? influencerId,
    String? brandId,
    String? brandName,
    String? brandEmail,
    String? brandCategory,
    String? brandLocation,
    DateTime? createdAt,
    bool? notifiedViaEmail,
    String? brandPhone,
    String? brandArea,
    bool? isDirectConnect,
    bool? isUnlockedByCreator,
  }) {
    return ProfileView(
      id: id ?? this.id,
      influencerId: influencerId ?? this.influencerId,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      brandEmail: brandEmail ?? this.brandEmail,
      brandCategory: brandCategory ?? this.brandCategory,
      brandLocation: brandLocation ?? this.brandLocation,
      createdAt: createdAt ?? this.createdAt,
      notifiedViaEmail: notifiedViaEmail ?? this.notifiedViaEmail,
      brandPhone: brandPhone ?? this.brandPhone,
      brandArea: brandArea ?? this.brandArea,
      isDirectConnect: isDirectConnect ?? this.isDirectConnect,
      isUnlockedByCreator: isUnlockedByCreator ?? this.isUnlockedByCreator,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'influencer_id': influencerId,
      'brand_name': brandName,
      'brand_email': brandEmail,
      'brand_category': brandCategory,
      'brand_location': brandLocation,
      'created_at': createdAt.toIso8601String(),
      'notified_via_email': notifiedViaEmail,
    };
  }
}
