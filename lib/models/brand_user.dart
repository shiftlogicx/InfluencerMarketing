class BrandUser {
  final String id;
  final String email;
  final String name;
  final String companyName;
  final String city;
  final String area;
  final String phone;
  final bool subscriptionStatus;
  final DateTime? subscriptionExpiry;

  const BrandUser({
    required this.id,
    required this.email,
    required this.name,
    required this.companyName,
    required this.city,
    this.area = "Koregaon Park",
    this.phone = "+91 98220 81132",
    this.subscriptionStatus = false,
    this.subscriptionExpiry,
  });

  bool get isSubscribed => subscriptionStatus && (subscriptionExpiry == null || subscriptionExpiry!.isAfter(DateTime.now()));

  BrandUser copyWith({
    String? id,
    String? email,
    String? name,
    String? companyName,
    String? city,
    String? area,
    String? phone,
    bool? subscriptionStatus,
    DateTime? subscriptionExpiry,
  }) {
    return BrandUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      city: city ?? this.city,
      area: area ?? this.area,
      phone: phone ?? this.phone,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'email': email,
      'company_name': companyName,
      'city': city,
      'phone': phone,
      'subscription_status': subscriptionStatus,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
    };
  }
}
