class RazorpayService {
  static const String defaultKeyId = "rzp_test_InfluencerPulse2026";
  static const String merchantName = "Influencer Pulse Technologies";
  static const String merchantEmail = "shiftlogiciq@gmail.com";

  static Map<String, dynamic> createCheckoutOptions({
    required String title,
    required double amountInInr,
    required String description,
    required String userEmail,
    required String userContact,
    String? orderId,
  }) {
    return {
      "key": defaultKeyId,
      "amount": (amountInInr * 100).toInt(), // Razorpay expects amount in paise
      "name": merchantName,
      "description": description,
      "image": "https://img.icons8.com/isometric/512/lightning-bolt.png",
      "prefill": {
        "email": userEmail.isNotEmpty ? userEmail : merchantEmail,
        "contact": userContact.isNotEmpty ? userContact : "+919876543210",
      },
      "theme": {
        "color": "#2997FF",
      },
      "modal": {
        "backdropclose": false,
        "escape": false,
      }
    };
  }
}
