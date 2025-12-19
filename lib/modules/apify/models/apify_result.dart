class ApifyResult {
  final List<dynamic> items;
  
  ApifyResult({required this.items});
  
  factory ApifyResult.fromJson(dynamic json) {
    if (json is List) {
      return ApifyResult(items: json);
    }
    if (json is Map<String, dynamic>) {
      final data = json['data'] ?? json['output'] ?? json;
      final items = (data['items'] ?? json['items']) is List 
        ? List<dynamic>.from(data['items'] ?? json['items']) 
        : (data is List ? List<dynamic>.from(data) : []);
    return ApifyResult(items: items); }
    
    return ApifyResult(items: []);
  }
}
