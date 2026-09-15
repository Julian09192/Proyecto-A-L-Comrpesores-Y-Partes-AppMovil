import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 Importante para los formateadores de texto numérico
import 'package:image_picker/image_picker.dart';
import '../../../models/products/producto_model.dart';
import '../../../services/products/producto_service.dart';

class EditProduct extends StatefulWidget {
  final ProductoModel? producto;
  final VoidCallback? onSaved;

  const EditProduct({
    super.key,
    this.producto,
    this.onSaved,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final ProductoService _productoService = ProductoService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _caracteristicasController;
  late TextEditingController _precioController;
  late TextEditingController _codigoController;
  late TextEditingController _marcaController;
  late TextEditingController _stockController;

  String _tipoSeleccionado = 'Aceite';
  bool _guardando = false;

  File? _imagenLocalFile;
  String? _imagenUrlExistente;
  final ImagePicker _picker = ImagePicker();

  final List<String> _tiposDisponibles = [
    'Aceite',
    'Tornillo',
    'Pistón',
    'Filtros',
    'Libres de Aire',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _caracteristicasController =
        TextEditingController(text: p?.caracteristicas ?? '');
    _precioController = TextEditingController(
      text: p != null ? p.precio.toStringAsFixed(0) : '',
    );
    _codigoController =
        TextEditingController(text: p?.codigoInterno ?? '');
    _marcaController = TextEditingController(text: p?.marca ?? 'Fleetguard');
    _stockController =
        TextEditingController(text: p != null ? p.stockTotal.toString() : '0');
    _imagenUrlExistente = p?.imagenUrl;

    if (p != null && _tiposDisponibles.contains(p.tipo)) {
      _tipoSeleccionado = p.tipo;
    } else if (p != null && p.tipo.isNotEmpty) {
      _tiposDisponibles.add(p.tipo);
      _tipoSeleccionado = p.tipo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _caracteristicasController.dispose();
    _precioController.dispose();
    _codigoController.dispose();
    _marcaController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _obtenerImagen(ImageSource source) async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (imagenSeleccionada != null) {
        setState(() {
          _imagenLocalFile = File(imagenSeleccionada.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la imagen: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarOpcionesDeImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Wrap(
              children: [
                const Text(
                  'Fotografía del producto',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0F2537),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF222222), size: 20),
                  ),
                  title: const Text('Elegir de la galería', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _obtenerImagen(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF222222), size: 20),
                  ),
                  title: const Text('Tomar una foto con la cámara', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _obtenerImagen(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final nombre = _nombreController.text.trim();
      final caracteristicas = _caracteristicasController.text.trim();
      final precio = double.tryParse(_precioController.text.trim()) ?? 0.0;
      final codigo = _codigoController.text.trim();
      final marca = _marcaController.text.trim();
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;

      final String? imagenFinalUrl = _imagenLocalFile != null 
          ? _imagenLocalFile!.path 
          : _imagenUrlExistente;

      if (widget.producto != null) {
        await _productoService.update(widget.producto!.id, {
          'nombre': nombre,
          'caracteristicas': caracteristicas,
          'precio': precio,
          'codigo_interno': codigo,
          'marca': marca,
          'stock_total': stock,
          'tipo': _tipoSeleccionado,
          if (imagenFinalUrl != null && imagenFinalUrl.isNotEmpty) 'imagen_url': imagenFinalUrl,
        });
      } else {
        await _productoService.crear(
          nombre: nombre,
          descripcion: caracteristicas,
          precio: precio,
          stock: stock,
          idCategoria: _tipoSeleccionado,
          marca: marca,
          codigoInterno: codigo,
          imagenUrl: imagenFinalUrl,
        );
      }

      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.producto != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      esEdicion ? 'Editar Producto' : 'Nuevo Producto',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2537)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildDropdownTipo(),
                const SizedBox(height: 16),
                const Text(
                  'FOTOGRAFÍA DEL PRODUCTO',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7A837E)),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: _mostrarOpcionesDeImagen,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _imagenLocalFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_imagenLocalFile!, fit: BoxFit.cover),
                            )
                          : (_imagenUrlExistente != null && _imagenUrlExistente!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    _imagenUrlExistente!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderCamara(),
                                  ),
                                )
                              : _buildPlaceholderCamara()),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'NOMBRE DEL PRODUCTO',
                  controller: _nombreController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'CARACTERÍSTICAS / DESCRIPCIÓN',
                  controller: _caracteristicasController,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'PRECIO (\$)',
                        controller: _precioController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          final numPrecio = double.tryParse(v.trim());
                          if (numPrecio == null) return 'Número inválido';
                          if (numPrecio < 0) return 'No puede ser negativo';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        label: 'CÓDIGO INTERNO',
                        controller: _codigoController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'MARCA',
                        controller: _marcaController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        label: 'STOCK DISPONIBLE',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          final numStock = int.tryParse(v.trim());
                          if (numStock == null) return 'Solo números enteros';
                          if (numStock < 0) return 'No puede ser negativo';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB913),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : Text(
                            esEdicion ? 'Guardar Cambios' : 'Crear Producto',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCamara() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: const Icon(Icons.add_a_photo_rounded, size: 24, color: Color(0xFF7A837E)),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para tomar una foto o adjuntar',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters, // 👈 Añadido para aceptar filtros de escritura
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7A837E),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters, // 👈 Aplicado aquí
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFDB913), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPO DE PRODUCTO',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7A837E),
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _tipoSeleccionado,
          isExpanded: true,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFDB913), width: 1.5),
            ),
          ),
          items: _tiposDisponibles.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(tipo),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _tipoSeleccionado = val);
            }
          },
        ),
      ],
    );
  }
}