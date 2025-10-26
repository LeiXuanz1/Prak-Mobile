class ApifyResult {
  final List<dynamic> items;
  
  ApifyResult({required this.items});
  
  factory ApifyResult.fromJson(dynamic json) {
    // CASE 1: Respons berupa list langsung
    if (json is List) {
      return ApifyResult(items: json);
    } // CASE 2: Respons berupa map dengan field data/output/items
    if (json is Map<String, dynamic>) {
      final data = json['data'] ?? json['output'] ?? json;
      final items = (data['items'] ?? json['items']) is List 
        ? List<dynamic>.from(data['items'] ?? json['items']) 
        : (data is List ? List<dynamic>.from(data) : []);
    return ApifyResult(items: items); }
    
    // CASE 3: Default fallback (tidak dikenal)
    return ApifyResult(items: []);
  }
}