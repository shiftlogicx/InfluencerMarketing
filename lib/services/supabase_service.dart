import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/influencer.dart';
import '../models/brand_user.dart';
import '../models/profile_view.dart';
import 'mock_data.dart';

class SupabaseService {
  static const String url = "https://zmbutpslrmbrqncuiowr.supabase.co";
  static const String apiKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptYnV0cHNscm1icnFuY3Vpb3dyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MzEyMzUwNSwiZXhwIjoyMTA4Njk5NTA1fQ.8BI7ssPAeY2CAtca1F3tCfHC1w1wt-rd4ssYM59sGkM";

  static Map<String, String> get _headers => {
        "apikey": apiKey,
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
      };

  // -------------------------------------------------------------
  // SUPABASE STORAGE: Creator Portfolio Images
  // -------------------------------------------------------------
  static Future<String?> uploadPortfolioImageBytes({
    required List<int> bytes,
    required String filename,
    String contentType = "image/jpeg",
  }) async {
    try {
      final uploadUrl = "$url/storage/v1/object/creator-portfolio/$filename";
      final res = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          "apikey": apiKey,
          "Authorization": "Bearer $apiKey",
          "Content-Type": contentType,
          "x-upsert": "true",
        },
        body: bytes,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return "$url/storage/v1/object/public/creator-portfolio/$filename";
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // AUTH & CREDENTIALS: app_credentials table
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>> signUpWithCredentials({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final cleanEmail = email.toLowerCase().trim();
      final payload = {
        "email": cleanEmail,
        "password_hash": password,
        "name": name.trim().isNotEmpty ? name.trim() : cleanEmail.split('@')[0],
        "role": role,
        "auth_provider": "email",
        "is_onboarded": false,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final res = await http.post(
        Uri.parse("$url/rest/v1/app_credentials"),
        headers: {
          ..._headers,
          "Prefer": "return=representation",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return {"success": true, "user": data.isNotEmpty ? data[0] : payload};
      } else {
        return {"success": false, "error": "An account already exists with this email. Please Sign In."};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> signInWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.toLowerCase().trim();
      final res = await http.get(
        Uri.parse("$url/rest/v1/app_credentials?email=eq.${Uri.encodeComponent(cleanEmail)}&select=*"),
        headers: _headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          final user = data[0];
          if (user['password_hash'] == password) {
            return {"success": true, "user": user};
          } else {
            return {"success": false, "error": "Incorrect password. Please verify your credentials."};
          }
        } else {
          return {"success": false, "error": "No account found with this email. Please create an account."};
        }
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
    return {"success": false, "error": "Authentication request failed. Please check network."};
  }

  static Future<Map<String, dynamic>> syncGoogleUser({
    required String email,
    required String name,
    required String role,
    String photoUrl = "",
  }) async {
    try {
      final cleanEmail = email.toLowerCase().trim();
      final checkRes = await http.get(
        Uri.parse("$url/rest/v1/app_credentials?email=eq.${Uri.encodeComponent(cleanEmail)}&select=*"),
        headers: _headers,
      );

      if (checkRes.statusCode == 200) {
        final List<dynamic> existing = jsonDecode(checkRes.body);
        if (existing.isNotEmpty) {
          return {"success": true, "user": existing[0], "isNew": false};
        }
      }

      final payload = {
        "email": cleanEmail,
        "password_hash": "google_oauth_token",
        "name": name.trim().isNotEmpty ? name.trim() : cleanEmail.split('@')[0],
        "role": role,
        "auth_provider": "google",
        "is_onboarded": false,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final res = await http.post(
        Uri.parse("$url/rest/v1/app_credentials"),
        headers: {
          ..._headers,
          "Prefer": "return=representation,resolution=merge-duplicates",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return {"success": true, "user": data.isNotEmpty ? data[0] : payload, "isNew": true};
      }
    } catch (_) {}
    return {
      "success": true,
      "user": {"email": email, "name": name, "role": role, "is_onboarded": false},
      "isNew": true
    };
  }

  static Future<void> markUserOnboarded(String email) async {
    try {
      await http.patch(
        Uri.parse("$url/rest/v1/app_credentials?email=eq.${Uri.encodeComponent(email.toLowerCase().trim())}"),
        headers: _headers,
        body: jsonEncode({"is_onboarded": true, "updated_at": DateTime.now().toIso8601String()}),
      );
    } catch (_) {}
  }

  // -------------------------------------------------------------
  // CREATORS: users_influencer table
  // -------------------------------------------------------------
  static Future<List<Influencer>> fetchInfluencers() async {
    try {
      final res = await http.get(
        Uri.parse("$url/rest/v1/users_influencer?select=*&order=created_at.desc"),
        headers: _headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          return data.map((item) => _mapJsonToInfluencer(item)).toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return MockData.initialInfluencers;
  }

  static Future<bool> saveInfluencer(Influencer inf, {double? lat, double? lng, bool isOnboarded = true}) async {
    try {
      final payload = {
        "id": inf.id.length >= 36 ? inf.id : "a1000000-0000-0000-0000-00000000000${inf.id.hashCode.abs() % 10000}",
        "name": inf.name,
        "age": inf.age,
        "address": inf.address,
        "city": inf.city,
        "state": inf.state,
        "contact_primary": inf.contactPrimary,
        "contact_secondary": inf.contactSecondary,
        "email_personal": inf.emailPersonal,
        "email_work": inf.emailWork,
        "social_links": inf.socialLinks,
        "collabs": inf.collabs,
        "category": inf.category,
        "price_per_reel": inf.pricePerReel,
        "portfolio_images": inf.portfolioImages,
        "membership_tier": inf.membershipTier,
        "bio": inf.bio,
        "followers_count": inf.followersCount,
        "rating": inf.rating,
        "impressions_count": inf.impressionsCount,
        "views_count": inf.viewsCount,
        if (lat != null) "latitude": lat,
        if (lng != null) "longitude": lng,
        "is_onboarded": isOnboarded,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final res = await http.post(
        Uri.parse("$url/rest/v1/users_influencer"),
        headers: {
          ..._headers,
          "Prefer": "resolution=merge-duplicates",
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 201 || res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // BRANDS: users_brand table
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>?> fetchBrandByPhone(String phone) async {
    try {
      final clean = phone.replaceAll(' ', '').replaceAll('-', '');
      final res = await http.get(
        Uri.parse("$url/rest/v1/users_brand?phone=eq.${Uri.encodeComponent(clean)}&limit=1"),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) return data[0] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> fetchInfluencerByPhone(String phone) async {
    try {
      final clean = phone.replaceAll(' ', '').replaceAll('-', '');
      final res = await http.get(
        Uri.parse("$url/rest/v1/users_influencer?contact_primary=eq.${Uri.encodeComponent(clean)}&limit=1"),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) return data[0] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> upsertBrand(
    BrandUser brand, {
    double? lat,
    double? lng,
    String? contactPerson,
    String? phone,
    String? industry,
    bool? isOnboarded,
  }) async {
    try {
      final payload = {
        "id": brand.id.length >= 36 ? brand.id : "b1000000-0000-0000-0000-000000000001",
        "email": brand.email,
        "company_name": brand.companyName,
        "city": brand.city,
        "subscription_status": brand.subscriptionStatus,
        "subscription_expiry": brand.subscriptionExpiry?.toIso8601String(),
        if (lat != null) "latitude": lat,
        if (lng != null) "longitude": lng,
        if (contactPerson != null) "contact_person": contactPerson,
        if (phone != null || brand.phone.isNotEmpty) "phone": phone ?? brand.phone,
        if (industry != null) "industry": industry,
        if (isOnboarded != null) "is_onboarded": isOnboarded,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final res = await http.post(
        Uri.parse("$url/rest/v1/users_brand"),
        headers: {
          ..._headers,
          "Prefer": "resolution=merge-duplicates",
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 201 || res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // PROFILE VIEWS: profile_views table
  // -------------------------------------------------------------
  static Future<bool> recordProfileView(ProfileView view) async {
    try {
      final payload = {
        "influencer_id": view.influencerId.length >= 36
            ? view.influencerId
            : "a1000000-0000-0000-0000-000000000001",
        "brand_name": view.brandName,
        "brand_email": view.brandEmail,
        "brand_category": view.brandCategory,
        "brand_location": view.brandLocation,
        "created_at": view.createdAt.toIso8601String(),
        "notified_via_email": view.notifiedViaEmail,
      };

      final res = await http.post(
        Uri.parse("$url/rest/v1/profile_views"),
        headers: _headers,
        body: jsonEncode(payload),
      );

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ProfileView>> fetchProfileViews() async {
    try {
      final res = await http.get(
        Uri.parse("$url/rest/v1/profile_views?select=*&order=created_at.desc&limit=25"),
        headers: _headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((item) {
          return ProfileView(
            id: item['id']?.toString() ?? "view_${DateTime.now().millisecondsSinceEpoch}",
            influencerId: item['influencer_id']?.toString() ?? "",
            brandId: item['brand_id']?.toString() ?? "",
            brandName: item['brand_name']?.toString() ?? "Verified Brand",
            brandEmail: item['brand_email']?.toString() ?? "",
            brandCategory: item['brand_category']?.toString() ?? "Campaign",
            brandLocation: item['brand_location']?.toString() ?? "Pune",
            createdAt: item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now(),
            notifiedViaEmail: item['notified_via_email'] ?? true,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  static Influencer _mapJsonToInfluencer(Map<String, dynamic> json) {
    Map<String, String> social = {};
    if (json['social_links'] is Map) {
      (json['social_links'] as Map).forEach((k, v) {
        social[k.toString()] = v?.toString() ?? "";
      });
    }

    List<String> collabs = [];
    if (json['collabs'] is List) {
      collabs = (json['collabs'] as List).map((e) => e.toString()).toList();
    }

    List<String> images = [];
    if (json['portfolio_images'] is List) {
      images = (json['portfolio_images'] as List).map((e) => e.toString()).toList();
    }

    return Influencer(
      id: json['id']?.toString() ?? "inf_${DateTime.now().millisecondsSinceEpoch}",
      name: json['name']?.toString() ?? "Creator",
      age: int.tryParse(json['age']?.toString() ?? "24") ?? 24,
      address: json['address']?.toString() ?? "",
      city: json['city']?.toString() ?? "Pune",
      state: json['state']?.toString() ?? "Maharashtra",
      contactPrimary: json['contact_primary']?.toString() ?? "+91 98000 00000",
      contactSecondary: json['contact_secondary']?.toString() ?? "",
      emailPersonal: json['email_personal']?.toString() ?? "creator@gmail.com",
      emailWork: json['email_work']?.toString() ?? "creator.work@gmail.com",
      socialLinks: social,
      collabs: collabs,
      category: json['category']?.toString() ?? "Food Blogger",
      pricePerReel: double.tryParse(json['price_per_reel']?.toString() ?? "2000") ?? 2000.0,
      portfolioImages: images.isNotEmpty ? images : [
        "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80"
      ],
      membershipTier: json['membership_tier']?.toString() ?? "gold",
      membershipExpiry: json['membership_expiry'] != null ? DateTime.tryParse(json['membership_expiry']) : null,
      bio: json['bio']?.toString() ?? "",
      followersCount: json['followers_count']?.toString() ?? "45K",
      rating: double.tryParse(json['rating']?.toString() ?? "4.9") ?? 4.9,
      impressionsCount: int.tryParse(json['impressions_count']?.toString() ?? "0") ?? 0,
      viewsCount: int.tryParse(json['views_count']?.toString() ?? "0") ?? 0,
    );
  }
}
