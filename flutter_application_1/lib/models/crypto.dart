import 'dart:convert';


List<Crypto> cryptoFromJson(String str) =>
    List<Crypto>.from(json.decode(str).map((x) => Crypto.fromJson(x)));

class Crypto {
  final String id;
  final String symbol;
  final String name;
  final String? imageUrl;
  final double currentPrice;
  final int marketCapRank;
  final double priceChangePercentage24h;
  final double totalVolume;
  final double ath;
  final double athChangePercentage;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
    required this.totalVolume,
    required this.ath,
    required this.athChangePercentage,
  });

  
  factory Crypto.fromJson(Map<String, dynamic> json) => Crypto(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
        imageUrl: json["image"],
        currentPrice: (json["current_price"] as num).toDouble(),
        marketCapRank: json["market_cap_rank"],
        priceChangePercentage24h:
            (json["price_change_percentage_24h"] as num).toDouble(),
        totalVolume: (json["total_volume"] as num? ?? 0).toDouble(),
        ath: (json["ath"] as num? ?? 0).toDouble(),
        athChangePercentage:
            (json["ath_change_percentage"] as num? ?? 0).toDouble(),
      );
}