import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNew = notification['isNew'] == true || notification['leida'] == false;
    final String initials = notification['initials'] ?? 'AL';
    final String sku = notification['sku'] ?? '';
    final String title = notification['title'] ?? '';
    final String units = notification['units'] ?? '0';
    final String imagenUrl = notification['imagenUrl'] ?? notification['imagen_url'] ?? '';
    final bool isSuspended = title.toLowerCase().contains('suspendido');
    
    String rawDate = notification['date'] ?? '';
    if (rawDate.contains('T')) {
      rawDate = rawDate.split('T').first;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFFDFBF5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNew ? const Color(0xFFFDB913).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isNew
            ? [BoxShadow(color: const Color(0xFFFDB913).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {}, // Acción futura al tocar la notificación
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚀 Contenedor de Imagen o Iniciales
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: imagenUrl.trim().isNotEmpty
                      ? Image.network(
                          imagenUrl.trim(),
                          fit: BoxFit.cover,
                          width: 46,
                          height: 46,
                          errorBuilder: (_, __, ___) => Text(
                            initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFF7A837E),
                            ),
                          ),
                        )
                      : Text(
                          initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF7A837E),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sku,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7A837E),
                            ),
                          ),
                          Row(
                            children: [
                              if (rawDate.isNotEmpty && rawDate != 'Inventario actual')
                                Text(
                                  rawDate,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              if (isNew)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFDB913),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2537),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Estado y Acciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuspended ? Colors.grey.shade100 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isSuspended 
                                  ? 'Producto inactivo' 
                                  : 'Estado crítico: Quedan $units unidades.',
                              style: TextStyle(
                                color: isSuspended ? Colors.grey.shade700 : Colors.red.shade700,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Text(
                                'Ocultar',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}