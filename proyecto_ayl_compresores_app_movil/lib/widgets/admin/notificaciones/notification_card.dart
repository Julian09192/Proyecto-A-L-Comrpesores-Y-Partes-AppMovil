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
    
    String rawDate = notification['date'] ?? '';
    if (rawDate.contains('T')) {
      rawDate = rawDate.split('T').first;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra lateral indicadora
              Container(
                width: 5,
                color: isNew ? const Color(0xFFFDB913) : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🚀 Contenedor de Imagen o Iniciales
                      Container(
                        width: 48,
                        height: 48,
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
                                width: 48,
                                height: 48,
                                errorBuilder: (_, __, ___) => Text(
                                  initials,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Color(0xFF0F2537),
                                  ),
                                ),
                              )
                            : Text(
                                initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Color(0xFF0F2537),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7A837E),
                                  ),
                                ),
                                if (rawDate.isNotEmpty && rawDate != 'Inventario actual')
                                  Text(
                                    rawDate,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F2537),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            
                            // Estado crítico detallado
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Estado crítico: Solo quedan $units unidades en inventario total.',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Pie de tarjeta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (isNew)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDB913),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'NUEVA',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                
                                InkWell(
                                  onTap: onDelete,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      'Borrar',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11.5,
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
            ],
          ),
        ),
      ),
    );
  }
}