class ProductFormData {
  final String title;
  final String category;
  final int stock;
  final String unit;
  final double price;
  final String packaging;
  final String description;
  final String? imagePath;

  ProductFormData({
    required this.title,
    required this.category,
    required this.stock,
    required this.unit,
    required this.price,
    required this.packaging,
    required this.description,
    this.imagePath,
  });
}
