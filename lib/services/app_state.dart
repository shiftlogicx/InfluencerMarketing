import 'package:flutter/material.dart';
import '../models/influencer.dart';
import '../models/brand_user.dart';
import '../models/profile_view.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  // Navigation State: whether user is on the Public Homepage or inside the Platform Dashboard
  bool _isInApp = false;
  bool get isInApp => _isInApp;

  // Authentication State
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String _userEmail = "";
  String get userEmail => _userEmail;

  String _userName = "";
  String get userName => _userName;

  String _userPhone = "";
  String get userPhone => _userPhone;

  String _brandArea = "Koregaon Park";
  String get brandArea => _brandArea;

  String _userPhotoUrl = "";
  String get userPhotoUrl => _userPhotoUrl;

  // Onboarding state: whether user has finished first-time role setup
  bool _isOnboarded = true;
  bool get isOnboarded => _isOnboarded;

  // Real Geolocation coordinates
  double _latitude = 18.5204;
  double _longitude = 73.8567;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get coordinatesText => "${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E";

  // Theme preference
  String _selectedTheme = "Space Black";
  String get selectedTheme => _selectedTheme;

  // Role: 'brand' (Business / Customer) or 'influencer' (Creator)
  String _currentRole = 'brand';
  String get currentRole => _currentRole;
  bool get isBrand => _currentRole == 'brand';
  bool get isCreator => _currentRole == 'influencer';

  // Active Brand User
  BrandUser _brandUser = BrandUser(
    id: "b1000000-0000-0000-0000-000000000001",
    email: "",
    name: "Brand Partner",
    companyName: "Brand Enterprise",
    city: "Pune",
    subscriptionStatus: false,
    subscriptionExpiry: null,
  );
  BrandUser get brandUser => _brandUser;

  // Active Influencer Profile (for creator portal view)
  late Influencer _activeInfluencer;
  Influencer get activeInfluencer => _activeInfluencer;

  // Master Influencers List
  List<Influencer> _influencers = List.from(MockData.initialInfluencers);
  List<Influencer> get influencers => _influencers;

  // Set of unlocked creator IDs for the brand
  final Set<String> _unlockedCreatorIds = {};
  Set<String> get unlockedCreatorIds => _unlockedCreatorIds;

  bool isCreatorUnlocked(String influencerId) {
    return _brandUser.isSubscribed || _unlockedCreatorIds.contains(influencerId);
  }

  // Search & Filter State
  String _selectedCategory = "All Categories";
  String get selectedCategory => _selectedCategory;

  String _selectedCity = "Pune";
  String get selectedCity => _selectedCity;

  RangeValues _priceRange = const RangeValues(500, 10000);
  RangeValues get priceRange => _priceRange;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  bool _isGeoLocationEnabled = true;
  bool get isGeoLocationEnabled => _isGeoLocationEnabled;

  String _detectedCity = "Pune";
  String get detectedCity => _detectedCity;

  // Profile Views History
  List<ProfileView> _profileViews = [];
  List<ProfileView> get profileViews => _profileViews;

  // Toast / Status Message
  String? _statusBanner;
  String? get statusBanner => _statusBanner;

  bool _isSyncingWithDb = false;
  bool get isSyncingWithDb => _isSyncingWithDb;

  AppState() {
    _activeInfluencer = _influencers[0];
    _seedInitialViews();
    loadFromSupabase();
  }

  void _seedInitialViews() {
    _profileViews = [
      ProfileView(
        id: "view_seed_01",
        influencerId: _activeInfluencer.id,
        brandId: "brand_swiggy_01",
        brandName: "Swiggy Gourmet",
        brandEmail: "marketing@swiggy.in",
        brandCategory: "Food & Beverage",
        brandLocation: "Koregaon Park, Pune",
        brandArea: "Koregaon Park",
        brandPhone: "+91 98220 11440",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        notifiedViaEmail: true,
        isDirectConnect: false,
        isUnlockedByCreator: false,
      ),
      ProfileView(
        id: "view_seed_02",
        influencerId: _activeInfluencer.id,
        brandId: "brand_zomato_01",
        brandName: "Zomato Gold Events",
        brandEmail: "partnerships@zomato.com",
        brandCategory: "Direct Connection Request",
        brandLocation: "FC Road, Pune",
        brandArea: "FC Road",
        brandPhone: "+91 91580 99882",
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        notifiedViaEmail: true,
        isDirectConnect: true,
        isUnlockedByCreator: true,
      ),
    ];
  }

  // Asynchronously load real remote data from Supabase
  Future<void> loadFromSupabase() async {
    _isSyncingWithDb = true;
    try {
      final dbInfluencers = await SupabaseService.fetchInfluencers();
      if (dbInfluencers.isNotEmpty) {
        _influencers = dbInfluencers;
        _activeInfluencer = _influencers.firstWhere(
          (inf) => inf.membershipTier == 'gold',
          orElse: () => _influencers[0],
        );
      }

      final dbViews = await SupabaseService.fetchProfileViews();
      if (dbViews.isNotEmpty) {
        _profileViews = dbViews;
      }
    } catch (_) {
      // Keep fallbacks
    } finally {
      _isSyncingWithDb = false;
      notifyListeners();
    }
  }

  // Filtered and Sorted Creators
  List<Influencer> get filteredInfluencers {
    return _influencers.where((inf) {
      final matchesCategory = _selectedCategory == "All Categories" || inf.category == _selectedCategory;
      final matchesCity = _selectedCity == "All Locations" || inf.city.toLowerCase() == _selectedCity.toLowerCase();
      final matchesPrice = inf.pricePerReel >= _priceRange.start && inf.pricePerReel <= _priceRange.end;
      final matchesSearch = _searchQuery.isEmpty ||
          inf.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inf.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inf.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inf.collabs.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesCity && matchesPrice && matchesSearch;
    }).toList()
      ..sort((a, b) {
        if (a.isBurgundy && !b.isBurgundy) return -1;
        if (!a.isBurgundy && b.isBurgundy) return 1;
        if (a.isGold && !b.isGold) return -1;
        if (!a.isGold && b.isGold) return 1;
        return b.rating.compareTo(a.rating);
      });
  }

  // Brand's saved/unlocked creators
  List<Influencer> get unlockedInfluencers {
    return _influencers.where((inf) => _unlockedCreatorIds.contains(inf.id)).toList();
  }

  // Real Geolocation update
  void setCoordinates(double lat, double lng, {String? city}) {
    _latitude = lat;
    _longitude = lng;
    if (city != null && city.isNotEmpty) {
      _detectedCity = city;
      _selectedCity = city;
    } else {
      // Estimate region from coordinates
      if ((lat - 18.52).abs() < 1.0 && (lng - 73.85).abs() < 1.0) {
        _detectedCity = "Pune";
        _selectedCity = "Pune";
      } else if ((lat - 19.07).abs() < 1.0 && (lng - 72.87).abs() < 1.0) {
        _detectedCity = "Mumbai";
        _selectedCity = "Mumbai";
      } else if ((lat - 12.97).abs() < 1.5 && (lng - 77.59).abs() < 1.5) {
        _detectedCity = "Bengaluru";
        _selectedCity = "Bengaluru";
      } else if ((lat - 28.61).abs() < 1.5 && (lng - 77.20).abs() < 1.5) {
        _detectedCity = "Delhi NCR";
        _selectedCity = "Delhi NCR";
      }
    }

    if (isBrand) {
      SupabaseService.upsertBrand(_brandUser, lat: lat, lng: lng);
    } else {
      SupabaseService.saveInfluencer(_activeInfluencer, lat: lat, lng: lng);
    }

    _statusBanner = "Detected Location: Lat ${lat.toStringAsFixed(4)}°, Long ${lng.toStringAsFixed(4)}° ($detectedCity)";
    notifyListeners();
  }

  // Sign In / Authentication
  void signInWithGoogle({
    required String email,
    required String name,
    required String role,
    String photoUrl = "",
    bool isOnboarded = false,
  }) {
    _isAuthenticated = true;
    _isInApp = true;
    _userEmail = email.isNotEmpty ? email : "user@gmail.com";
    _userName = name.isNotEmpty ? name : _userEmail.split('@')[0];
    _userPhotoUrl = photoUrl;
    _currentRole = role;
    _isOnboarded = isOnboarded;

    if (role == 'brand') {
      _brandUser = _brandUser.copyWith(
        email: _userEmail,
        name: _userName,
      );
      SupabaseService.upsertBrand(_brandUser, isOnboarded: isOnboarded);
    } else {
      _activeInfluencer = _activeInfluencer.copyWith(
        emailWork: _userEmail,
        name: _userName,
      );
      SupabaseService.saveInfluencer(_activeInfluencer, isOnboarded: isOnboarded);
    }

    _statusBanner = "Authenticated as $_userName ($_userEmail)";
    notifyListeners();
  }

  void signInWithPhoneOtp({
    required String phone,
    required String role,
    bool isOnboarded = false,
    String? companyName,
    String? area,
    String? city,
    String? contactPerson,
    String? industry,
  }) {
    _isAuthenticated = true;
    _isInApp = true;
    _userPhone = phone;
    _userEmail = "${phone.replaceAll('+', '').replaceAll(' ', '')}@phone.pulse.in";
    _userName = contactPerson ?? (role == 'brand' ? (companyName ?? "Brand Partner") : "Creator");
    _currentRole = role;
    _isOnboarded = isOnboarded;

    if (area != null && area.isNotEmpty) {
      _brandArea = area;
    }
    if (city != null && city.isNotEmpty) {
      _selectedCity = city;
    }

    if (role == 'brand') {
      _brandUser = _brandUser.copyWith(
        phone: phone,
        companyName: companyName ?? _brandUser.companyName,
        name: contactPerson ?? _userName,
        city: city ?? _selectedCity,
        area: _brandArea,
        email: _userEmail,
      );
      SupabaseService.upsertBrand(_brandUser, phone: phone, isOnboarded: isOnboarded);
    } else {
      _activeInfluencer = _activeInfluencer.copyWith(
        contactPrimary: phone,
        name: _userName,
      );
      SupabaseService.saveInfluencer(_activeInfluencer, isOnboarded: isOnboarded);
    }

    _statusBanner = "Verified mobile number ($phone) via OTP";
    notifyListeners();
  }

  void completeBrandOnboarding({
    required String companyName,
    required String contactPerson,
    required String phone,
    required String industry,
    required String city,
    String area = "Koregaon Park",
  }) {
    _isOnboarded = true;
    _selectedCity = city;
    _brandArea = area.isNotEmpty ? area : "Koregaon Park";
    _userPhone = phone;
    _userName = contactPerson;

    _brandUser = _brandUser.copyWith(
      companyName: companyName,
      name: contactPerson,
      city: city,
      area: _brandArea,
      phone: phone,
    );

    SupabaseService.upsertBrand(
      _brandUser,
      contactPerson: contactPerson,
      phone: phone,
      industry: industry,
      isOnboarded: true,
      lat: _latitude,
      lng: _longitude,
    );
    SupabaseService.markUserOnboarded(_userEmail);

    _statusBanner = "Brand onboarding completed! Welcome to Influencer Pulse.";
    notifyListeners();
  }

  void completeCreatorOnboarding(Influencer updated) {
    _isOnboarded = true;
    _activeInfluencer = updated;
    final idx = _influencers.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _influencers[idx] = updated;
    } else {
      _influencers.insert(0, updated);
    }

    SupabaseService.saveInfluencer(updated, lat: _latitude, lng: _longitude, isOnboarded: true);
    SupabaseService.markUserOnboarded(_userEmail);

    _statusBanner = "Creator profile successfully published and saved to Supabase!";
    notifyListeners();
  }

  void enterAppWithRole(String role) {
    if (!_isAuthenticated) {
      _userEmail = "guest@gmail.com";
      _userName = "Guest User";
      _isAuthenticated = true;
    }
    _currentRole = role;
    _isInApp = true;
    notifyListeners();
  }

  void goToHome() {
    _isInApp = false;
    notifyListeners();
  }

  void switchRole(String role) {
    _currentRole = role;
    _statusBanner = role == 'brand' ? "Switched to Brand / Business view" : "Switched to Creator / Influencer view";
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _isInApp = false;
    _userEmail = "";
    _userName = "";
    _userPhotoUrl = "";
    _statusBanner = "Signed out successfully.";
    notifyListeners();
  }

  void setTheme(String theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  void updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? companyName,
  }) {
    if (name != null && name.isNotEmpty) _userName = name;
    if (email != null && email.isNotEmpty) _userEmail = email;
    if (photoUrl != null) _userPhotoUrl = photoUrl;

    if (isBrand) {
      _brandUser = _brandUser.copyWith(
        name: _userName,
        email: _userEmail,
        companyName: companyName ?? _brandUser.companyName,
      );
      SupabaseService.upsertBrand(_brandUser);
    } else {
      _activeInfluencer = _activeInfluencer.copyWith(
        name: _userName,
        emailWork: _userEmail,
      );
      SupabaseService.saveInfluencer(_activeInfluencer);
    }

    _statusBanner = "Profile settings updated and synced with Supabase.";
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void enableGeoLocation(String city) {
    _isGeoLocationEnabled = true;
    _detectedCity = city;
    _selectedCity = city;
    notifyListeners();
  }

  // Record profile click
  void recordProfileClick(Influencer clicked, List<Influencer> currentFeed) {
    for (int i = 0; i < currentFeed.length; i++) {
      if (currentFeed[i].id != clicked.id) {
        final index = _influencers.indexWhere((e) => e.id == currentFeed[i].id);
        if (index != -1) {
          _influencers[index] = _influencers[index].copyWith(
            impressionsCount: _influencers[index].impressionsCount + 1,
          );
        }
      }
    }

    final clickedIdx = _influencers.indexWhere((e) => e.id == clicked.id);
    if (clickedIdx != -1) {
      _influencers[clickedIdx] = _influencers[clickedIdx].copyWith(
        viewsCount: _influencers[clickedIdx].viewsCount + 1,
      );
    }

    final area = _brandUser.area.isNotEmpty ? _brandUser.area : _brandArea;
    final city = _brandUser.city.isNotEmpty ? _brandUser.city : _selectedCity;
    final phone = _brandUser.phone.isNotEmpty ? _brandUser.phone : (_userPhone.isNotEmpty ? _userPhone : "+91 98220 81132");

    final newView = ProfileView(
      id: "view_${DateTime.now().millisecondsSinceEpoch}",
      influencerId: clicked.id,
      brandId: _brandUser.id,
      brandName: _brandUser.companyName.isNotEmpty ? _brandUser.companyName : "Regional Enterprise Brand",
      brandEmail: _brandUser.email.isNotEmpty ? _brandUser.email : "campaigns@brand.in",
      brandCategory: clicked.category,
      brandLocation: "$area, $city",
      brandArea: area,
      brandPhone: phone,
      createdAt: DateTime.now(),
      notifiedViaEmail: true,
      isDirectConnect: false,
      isUnlockedByCreator: false,
    );
    _profileViews.insert(0, newView);

    SupabaseService.recordProfileView(newView);
    notifyListeners();
  }

  // Unlock single creator coordinates or full Brand Pass (Promo: ₹0 ~₹49~)
  void unlockDirectContact(String influencerId) {
    _unlockedCreatorIds.add(influencerId);
    _brandUser = _brandUser.copyWith(
      subscriptionStatus: true,
      subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
    );
    SupabaseService.upsertBrand(_brandUser, isOnboarded: true);

    final inf = _influencers.firstWhere((e) => e.id == influencerId, orElse: () => _activeInfluencer);
    final area = _brandUser.area.isNotEmpty ? _brandUser.area : _brandArea;
    final city = _brandUser.city.isNotEmpty ? _brandUser.city : _selectedCity;
    final phone = _brandUser.phone.isNotEmpty ? _brandUser.phone : (_userPhone.isNotEmpty ? _userPhone : "+91 98220 81132");

    final connectView = ProfileView(
      id: "view_connect_${DateTime.now().millisecondsSinceEpoch}",
      influencerId: influencerId,
      brandId: _brandUser.id,
      brandName: _brandUser.companyName.isNotEmpty ? _brandUser.companyName : (_userName.isNotEmpty ? _userName : "Verified Brand Partner"),
      brandEmail: _userEmail.isNotEmpty ? _userEmail : "brand.connect@pulse.in",
      brandCategory: "Direct Inquiry / Collaboration Request",
      brandLocation: "$area, $city",
      brandArea: area,
      brandPhone: phone,
      createdAt: DateTime.now(),
      notifiedViaEmail: true,
      isDirectConnect: true,
      isUnlockedByCreator: true,
    );
    _profileViews.insert(0, connectView);
    SupabaseService.recordProfileView(connectView);

    _statusBanner = "Inquiry Sent to ${inf.name} (~₹49~ FREE Promo)! Added to Unlocked Contacts.";
    notifyListeners();
  }

  // Influencer reveals who viewed their profile (~₹149~ ₹0 Free Promo)
  void unlockProfileViewDetails(String viewId) {
    final idx = _profileViews.indexWhere((v) => v.id == viewId);
    if (idx != -1) {
      _profileViews[idx] = _profileViews[idx].copyWith(isUnlockedByCreator: true);
      // Upgrade tier to Gold for 90 days for free
      _activeInfluencer = _activeInfluencer.copyWith(membershipTier: 'gold');
      _statusBanner = "Brand Details Unlocked (~₹149~ FREE Promo)! Verified direct phone number is now visible.";
      notifyListeners();
    }
  }

  // Razorpay Brand Subscription Unlock (₹49/month)
  void unlockBrandSubscription() {
    _brandUser = _brandUser.copyWith(
      subscriptionStatus: true,
      subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
    );
    SupabaseService.upsertBrand(_brandUser);
    _statusBanner = "Brand Pass Active: Direct coordinates unblurred across India.";
    notifyListeners();
  }

  // Influencer Membership Upgrade via Razorpay (Gold ₹149 / Burgundy ₹399)
  void upgradeInfluencerTier(String tier, {int days = 90}) {
    _activeInfluencer = _activeInfluencer.copyWith(
      membershipTier: tier,
      membershipExpiry: DateTime.now().add(Duration(days: days)),
    );

    final idx = _influencers.indexWhere((e) => e.id == _activeInfluencer.id);
    if (idx != -1) {
      _influencers[idx] = _activeInfluencer;
    }

    SupabaseService.saveInfluencer(_activeInfluencer);
    _statusBanner = "Membership Upgraded: You are now on ${tier.toUpperCase()} Tier via Razorpay!";
    notifyListeners();
  }

  // Update Influencer Portfolio
  Future<bool> updateActiveInfluencer(Influencer updated) async {
    _activeInfluencer = updated;
    final idx = _influencers.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _influencers[idx] = updated;
    } else {
      _influencers.insert(0, updated);
    }

    _statusBanner = "Saving portfolio to Supabase table (users_influencer)...";
    notifyListeners();

    final success = await SupabaseService.saveInfluencer(updated, lat: _latitude, lng: _longitude, isOnboarded: true);
    if (success) {
      _statusBanner = "Creator portfolio saved to Supabase (users_influencer) & published live!";
    } else {
      _statusBanner = "Portfolio published locally (Supabase synced in background).";
    }
    notifyListeners();
    return success;
  }

  void clearStatusBanner() {
    _statusBanner = null;
    notifyListeners();
  }
}
