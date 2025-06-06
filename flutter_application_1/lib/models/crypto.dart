// lib/models/crypto.dart

import 'dart:convert';

// Helper function to convert JSON list to a list of Crypto objects
List<Crypto> cryptoFromJson(String str) =>
    List<Crypto>.from(json.decode(str).map((x) => Crypto.fromJson(x)));

class Crypto {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final int marketCapRank;
  final double priceChangePercentage24h;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
  });

  // Factory constructor to create a Crypto instance from a JSON object
  factory Crypto.fromJson(Map<String, dynamic> json) => Crypto(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
        currentPrice: (json["current_price"] as num).toDouble(),
        marketCapRank: json["market_cap_rank"],
        priceChangePercentage24h:
            (json["price_change_percentage_24h"] as num).toDouble(),
      );
}