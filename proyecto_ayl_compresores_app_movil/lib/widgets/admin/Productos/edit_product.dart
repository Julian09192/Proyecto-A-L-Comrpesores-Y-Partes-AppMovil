import 'package:flutter/material.dart';
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
  late TextEditingController _imagenUrlController;

  String _tipoSeleccionado = 'Aceite';
  bool _guardando = false;

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
    _imagenUrlController = TextEditingController(text: p?.imagenUrl ?? '');

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
    _imagenUrlController.dispose();
    super.dispose();
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
      final imagenUrl = _imagenUrlController.text.trim();

      if (widget.producto != null) {
        // Actualizar
        await _productoService.update(widget.producto!.id, {
          'nombre': nombre,
          'caracteristicas': caracteristicas,
          'precio': precio,
          'codigo_interno': codigo,
          'marca': marca,
          'stock_total': stock,
          'tipo': _tipoSeleccionado,
          if (imagenUrl.isNotEmpty) 'imagen_url': imagenUrl,
        });
      } else {
        // Crear nuevo
        await _productoService.crear(
          nombre: nombre,
          descripcion: caracteristicas,
          precio: precio,
          stock: stock,
          idCategoria: _tipoSeleccionado,
          marca: marca,
          codigoInterno: codigo,
          imagenUrl: imagenUrl.isNotEmpty ? imagenUrl : null,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esEdicion ? 'Editar Producto' : 'Nuevo Producto',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Dropdown Tipo de Producto
                _buildDropdownTipo(),
                const SizedBox(height: 12),

                // URL de Imagen
                _buildTextField(
                  label: 'URL DE IMAGEN (OPCIONAL)',
                  controller: _imagenUrlController,
                  hint: 'https://ejemplo.com/imagen.jpg',
                ),
                const SizedBox(height: 12),

                // Nombre
                _buildTextField(
                  label: 'NOMBRE DEL PRODUCTO',
                  controller: _nombreController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 12),

                // Características
                _buildTextField(
                  label: 'CARACTERÍSTICAS / DESCRIPCIÓN',
                  controller: _caracteristicasController,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Fila Precio y Código
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'PRECIO (\$)',
                        controller: _precioController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'CÓDIGO INTERNO',
                        controller: _codigoController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fila Marca y Stock
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'MARCA',
                        controller: _marcaController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'STOCK DISPONIBLE',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF373A3E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                esEdicion ? 'Guardar Cambios' : 'Crear Producto',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
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
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _tipoSeleccionado,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          items: _tiposDisponibles.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(tipo, style: const TextStyle(fontSize: 13)),
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