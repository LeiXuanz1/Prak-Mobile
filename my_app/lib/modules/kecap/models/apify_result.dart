class ApifyResult {
  final String? id;
  final String? actId;
  final String? status;
  final dynamic data;
  final List<dynamic>? items;

  ApifyResult({
    this.id,
    this.actId,
    this.status,
    this.data,
    this.items,
  });

  factory ApifyResult.fromJson(Map<String, dynamic> json) {
    // Apify biasanya balikin data di bawah field 'data'
    final data = json['data'] ?? {};
    return ApifyResult(
      id: data['id'] ?? '',
      actId: data['actId'] ?? '',
      status: data['status'] ?? '',
      data: data,
      // beberapa run Apify mengembalikan 'items' dalam 'data' atau 'output'
      items: (data['items'] != null && data['items'] is List)
          ? List<dynamic>.from(data['items'])
          : (data['output']?['items'] != null
              ? List<dynamic>.from(data['output']['items'])
              : []),
    );
  }
}
