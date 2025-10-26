class SoySauce {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String link;

  SoySauce({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.link,
  });

  factory SoySauce.fromJson(Map<String, dynamic> json) {
    final priceInfo = json['price_instructions'] ?? {};
    return SoySauce(
      id: json['id'] ?? '',
      name: json['display_name'] ?? 'Unknown',
      imageUrl: json['thumbnail'] ?? '',
      price: double.tryParse(priceInfo['unit_price']?.toString() ?? '0') ?? 0,
      link: json['share_url'] ?? '',
    );
  }
}
