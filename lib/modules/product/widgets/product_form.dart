import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_form_data.dart';

class ProductForm extends StatefulWidget {
  final ProductFormData? initial;
  final String submitLabel;
  final void Function(ProductFormData data) onSubmit;

  const ProductForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;

  String _category = 'General';
  String _unit = 'Units';
  String _packaging = 'Bottle';

  String? _initialImagePath;
  File? _imageFile;
  final _picker = ImagePicker();

  String _safeDropdownValue(
    String? value,
    List<String> options,
    String fallback,
  ) {
    return options.contains(value) ? value! : fallback;
  }

  @override
  void initState() {
    super.initState();

    final i = widget.initial;

    _nameCtrl = TextEditingController(text: i?.title ?? '');
    _stockCtrl = TextEditingController(text: i?.stock.toString() ?? '');
    _priceCtrl = TextEditingController(text: i?.price.toString() ?? '');
    _descCtrl = TextEditingController(text: i?.description ?? '');

    _category = i?.category ?? 'General';
    _unit = i?.unit ?? 'Units';

    const packagingOptions = ['Bottle', 'Sachet', 'Pouch'];
    const unitOptions = ['Units', 'pcs', 'box', 'kg', 'liter'];

    _packaging = _safeDropdownValue(i?.packaging, packagingOptions, 'Bottle');
    _unit = _safeDropdownValue(i?.unit, unitOptions, 'Units');
    _category = _safeDropdownValue(i?.category, [
      'General',
      'Kecap',
      'Makanan',
      'Minuman',
    ],
    'General',
    );

    _initialImagePath = i?.imagePath;

    if (_initialImagePath != null &&
        !_initialImagePath!.startsWith('http') &&
        File(_initialImagePath!).existsSync()) {
      _imageFile = File(_initialImagePath!);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      ProductFormData(
        title: _nameCtrl.text.trim(),
        category: _category,
        stock: int.parse(_stockCtrl.text),
        unit: _unit,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        packaging: _packaging,
        description: _descCtrl.text.trim(),
        imagePath: _imageFile?.path ?? _initialImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _imagePicker(context),
          const SizedBox(height: 20),

          _field(_nameCtrl, 'Product Name', required: true),
          _dropdownCategory(),
          _dropdownPackaging(),
          _stockAndUnit(),
          _field(
            _priceCtrl,
            'Price',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          _field(_descCtrl, 'Description', maxLines: 3),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _imageFile != null
            ? Image.file(_imageFile!, fit: BoxFit.cover)
            : (_initialImagePath != null
                  ? Image.network(
                      _initialImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 48),
                    )
                  : const Center(child: Icon(Icons.image_outlined, size: 48))),
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
            value: _unit,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: const [
              DropdownMenuItem(value: 'Units', child: Text('Units')),
              DropdownMenuItem(value: 'pcs', child: Text('Pcs')),
              DropdownMenuItem(value: 'box', child: Text('Box')),
              DropdownMenuItem(value: 'kg', child: Text('Kg')),
              DropdownMenuItem(value: 'liter', child: Text('Liter')),
            ],
            onChanged: (v) => setState(() => _unit = v!),
          ),
        ),
      ],
    );
  }

  Widget _dropdownPackaging() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _packaging,
        decoration: const InputDecoration(labelText: 'Packaging'),
        items: const [
          DropdownMenuItem(value: 'Bottle', child: Text('Bottle')),
          DropdownMenuItem(value: 'Sachet', child: Text('Sachet')),
          DropdownMenuItem(value: 'Pouch', child: Text('Pouch')),
        ],
        onChanged: (v) => setState(() => _packaging = v!),
      ),
    );
  }
}
