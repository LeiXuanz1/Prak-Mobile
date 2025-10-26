class ApifyResult {
  final List<dynamic> items;

  ApifyResult({required this.items});

  factory ApifyResult.fromJson(dynamic json) {
    // Jika respons-nya berupa list langsung (bukan map)
    if (json is List) {
      return ApifyResult(items: json);
    }

    // Jika respons-nya object (map) dengan field data/output/items
    if (json is Map<String, dynamic>) {
      final data = json['data'] ?? json['output'] ?? {};
      final items = (data['items'] ?? data) is List
          ? List<dynamic>.from(data['items'] ?? data)
          : [];

      return ApifyResult(items: items);
    }

    // Default: tidak ada data
    return ApifyResult(items: []);
  }
}
