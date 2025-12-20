import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/data/local/controllers/hive_product_controller.dart';
import 'package:my_app/data/local/models/product_hive_model.dart';

class AddStockView extends StatefulWidget {
  final ProductHiveModel? productToEdit;
  const AddStockView({super.key, this.productToEdit});

  @override
  State<AddStockView> createState() => _AddStockViewState();
}

class _AddStockViewState extends State<AddStockView> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'Units');
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'General';

  File? _selectedImageFile;
  final _picker = ImagePicker();
  final _controller = Get.find<HiveProductController>();

  double get _stockValue {
    final stock = int.tryParse(_stockCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    return stock * price;
  }

  double get _unitPrice => double.tryParse(_priceCtrl.text) ?? 0;

  @override
  void initState() {
    super.initState();

    _stockCtrl.addListener(() => setState(() {}));
    _priceCtrl.addListener(() => setState(() {}));

    final edit = widget.productToEdit;
    if (edit != null) {
      _nameCtrl.text = edit.title;
      _category = edit.category;
      _stockCtrl.text = edit.stock.toString();
      _unitCtrl.text = edit.unit;
      _priceCtrl.text = edit.price.toString();
      _descCtrl.text = edit.description;

      if (edit.thumbnail != null &&
          File(edit.thumbnail!).existsSync()) {
        _selectedImageFile = File(edit.thumbnail!);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final sizeMb = await file.length() / (1024 * 1024);

    if (sizeMb > 5) {
      _snack('File terlalu besar', 'Maksimal 5 MB', isError: true);
      return;
    }

    setState(() => _selectedImageFile = file);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.productToEdit != null;

    final product = ProductHiveModel(
      id: isEdit
          ? widget.productToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameCtrl.text.trim(),
      category: _category,
      stock: int.parse(_stockCtrl.text),
      unit: _unitCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      thumbnail: _selectedImageFile?.path ??
          widget.productToEdit?.thumbnail,
      source: 'local',
      status: int.parse(_stockCtrl.text) > 20
          ? 'Available'
          : 'Low Stock',
    );

    isEdit
        ? _controller.updateProduct(product.id, product)
        : _controller.addProduct(product);

    Get.back();
    _snack('Berhasil', 'Produk berhasil disimpan');
  }

  void _snack(String title, String msg, {bool isError = false}) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productToEdit == null
            ? 'Add Product'
            : 'Edit Product'),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _imagePicker(cs),
            const SizedBox(height: 20),

            _field(_nameCtrl, 'Product Name', required: true),
            _dropdownCategory(),
            _stockAndUnit(),
            _field(
              _priceCtrl,
              'Price',
              keyboard: TextInputType.numberWithOptions(decimal: true),
            ),
            _field(_descCtrl, 'Description', maxLines: 3),

            const SizedBox(height: 16),
            _summary(cs),

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('Save Product'),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePicker(ColorScheme cs) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _selectedImageFile == null
            ? const Center(
                child: Icon(Icons.image_outlined, size: 48),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImageFile!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Required' : null
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdownCategory() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: const [
          DropdownMenuItem(value: 'General', child: Text('General')),
          DropdownMenuItem(value: 'Kecap', child: Text('Kecap')),
          DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
          DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
        ],
        onChanged: (v) => setState(() => _category = v!),
      ),
    );
  }

  Widget _stockAndUnit() {
    return Row(
      children: [
        Expanded(
          child: _field(
            _stockCtrl,
            'Stock',
            required: true,
            keyboard: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _unitCtrl.text,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: const [
              DropdownMenuItem(value: 'Units', child: Text('Units')),
              DropdownMenuItem(value: 'Pcs', child: Text('Pcs')),
              DropdownMenuItem(value: 'Box', child: Text('Box')),
              DropdownMenuItem(value: 'Kg', child: Text('Kg')),
              DropdownMenuItem(value: 'Liter', child: Text('Liter')),
            ],
            onChanged: (v) => setState(() => _unitCtrl.text = v!),
          ),
        ),
      ],
    );
  }

  Widget _summary(ColorScheme cs) {
    return Card(
      child: ListTile(
        title: const Text('Summary'),
        subtitle: Text(
          'Stock Value: ${_stockValue.toStringAsFixed(2)}\n'
          'Unit Price: ${_unitPrice.toStringAsFixed(2)}',
        ),
      ),
    );
  }
}
