import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesService {
  final _supabase = Supabase.instance.client;

  // Obtener todas las notificaciones ordenadas por fecha
  Future<List<Map<String, dynamic>>> obtenerNotificaciones() async {
    try {
      final response = await _supabase
          .from('notificaciones_stock')
          .select()
          .order('creado_en', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al cargar notificaciones: $e');
    }
  }

  // Marcar una notificación individual como leída
  Future<void> marcarComoLeida(dynamic id) async {
    try {
      await _supabase
          .from('notificaciones_stock')
          .update({'leido': true})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar notificación: $e');
    }
  }

  // 🚀 Marcar TODAS las notificaciones como leídas en Supabase
  Future<void> marcarTodasComoLeidas() async {
    try {
      await _supabase
          .from('notificaciones_stock')
          .update({'leido': true})
          .eq('leido', false); // Actualiza solo las que estén en false para optimizar
    } catch (e) {
      throw Exception('Error al marcar todas como leídas: $e');
    }
  }

  // Eliminar una notificación
  Future<void> eliminarNotificacion(dynamic id) async {
    try {
      await _supabase
          .from('notificaciones_stock')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar notificación: $e');
    }
  }
}