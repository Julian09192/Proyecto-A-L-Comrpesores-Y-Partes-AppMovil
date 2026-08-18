import 'package:flutter/material.dart';

class EditProduct extends StatelessWidget {
  const EditProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar Producto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Fila 1: Dropdowns corregidos
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      'TIPO DE PRODUCTO',
                      'Seleccione...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDropdownField(
                      'UBICACIÓN',
                      'Seleccione...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subir Imagen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    'Haz click para adjuntar una imagen',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campos principales
              _buildTextField('NOMBRE', 'Filtro Separador de Combustible FS-19732'),
              const SizedBox(height: 12),
              _buildTextField('CARACTERÍSTICAS', ''),
              const SizedBox(height: 12),

              // Fila 2: Precio y Código
              Row(
                children: [
                  Expanded(child: _buildTextField('PRECIO (\$)', '185000')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField('CÓDIGO INTERNO', 'FS-19732-001')),
                ],
              ),
              const SizedBox(height: 12),

              // Fila 3: Marca y Stock
              Row(
                children: [
                  Expanded(child: _buildTextField('MARCA', 'Fleetguard')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField('STOCK DISPONIBLE', '10')),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
    );
  }

  Widget _buildTextField(String label, String initialValue) {
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
          initialValue: initialValue,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
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

  Widget _buildDropdownField(String label, String hint) {
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
        DropdownButtonFormField<String>(
          isExpanded: true, // <--- Evita el overflow horizontal
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          items: const [],
          onChanged: (val) {},
        ),
      ],
    );
  }
}