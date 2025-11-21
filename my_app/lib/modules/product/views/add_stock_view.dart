import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/local/hive_models/product_hive_model.dart';

class AddStockView extends StatefulWidget {
  const AddStockView({super.key});

  @override
  State<AddStockView> createState() => _AddStockViewState();
}

class _AddStockViewState extends State<AddStockView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _category = 'General';
  final _stockCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'Units');
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _controller = Get.find<HiveProductController>();

  // Real-time calculation
  double get _stockValue {
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    return stock * price;
  }

  double get _unitPrice {
    return double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    // Listen to changes for real-time summary update
    _stockCtrl.addListener(() => setState(() {}));
    _priceCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final hiveProduct = ProductHiveModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameCtrl.text.trim(),
      category: _category,
      stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
      unit: _unitCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      description: _descCtrl.text.trim(),
      thumbnail: null,
      source: 'local',
      status: (int.tryParse(_stockCtrl.text.trim()) ?? 0) > 20
          ? 'Available'
          : 'Low Stock',
    );

    _controller.addProduct(hiveProduct);

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Produk "${_nameCtrl.text.trim()}" berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B00), Color(0xFFFF0000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fill in product details',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Product Name
                        _buildLabel('📦 Product Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter product name',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B00),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Product name is required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Category
                        _buildLabel('🏷️ Category'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: const [
                                DropdownMenuItem(
                                  value: 'General',
                                  child: Text('Select a category'),
                                ),
                                DropdownMenuItem(
                                  value: 'Kecap',
                                  child: Text('Kecap'),
                                ),
                                DropdownMenuItem(
                                  value: 'Makanan',
                                  child: Text('Makanan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Minuman',
                                  child: Text('Minuman'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _category = v ?? 'General'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stock Quantity & Unit
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('📊 Stock Quantity'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _stockCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF6B00),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Required';
                                      } if (int.tryParse(v.trim()) == null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Unit'),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _unitCtrl.text,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Units',
                                            child: Text('Units'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Pcs',
                                            child: Text('Pcs'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Box',
                                            child: Text('Box'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Kg',
                                            child: Text('Kg'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Liter',
                                            child: Text('Liter'),
                                          ),
                                        ],
                                        onChanged: (v) => setState(
                                          () => _unitCtrl.text = v ?? 'Units',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Price
                        _buildLabel('💰 Price'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '\$ 0.00',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B00),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter product description (optional)',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B00),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSummaryCard(
                                    'Stock Value',
                                    '\$${_stockValue.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSummaryCard(
                                    'Unit Price',
                                    '\$${_unitPrice.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Add Product Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B00), Color(0xFFFF0000)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF6B00,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cancel Button
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
