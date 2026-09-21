import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Definición de color rojo corporativo estándar
const Color empleadoRojo = Color(0xFFDC2626);
const Color empleadoRojoClaro = Color(0xFFEF4444);
const Color empleadoFondo = Color(0xFFF7F8FA);
const Color empleadoTexto = Color(0xFF0F2537);
const Color empleadoTextoSecundario = Color(0xFF7A837E);

class EmpleadoPerfilView extends StatefulWidget {
  const EmpleadoPerfilView({super.key});

  @override
  State<EmpleadoPerfilView> createState() => _EmpleadoPerfilViewState();
}

class _EmpleadoPerfilViewState extends State<EmpleadoPerfilView> {
  bool _loading = false;

  Future<void> _cambiarPassword() async {
    final passAnteriorController = TextEditingController();
    final passNuevaController = TextEditingController();
    final key = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Actualizar contraseña',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: empleadoTexto,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Form(
          key: key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Contraseña Anterior
                TextFormField(
                  controller: passAnteriorController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    labelStyle: const TextStyle(
                      color: empleadoTextoSecundario,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_open_rounded,
                      color: empleadoRojo,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: empleadoFondo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: empleadoRojo, width: 1.5),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa tu contraseña actual'
                      : null,
                ),
                const SizedBox(height: 16),
                // Contraseña Nueva
                TextFormField(
                  controller: passNuevaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    labelStyle: const TextStyle(
                      color: empleadoTextoSecundario,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: empleadoRojo,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: empleadoFondo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: empleadoRojo, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    if (value == passAnteriorController.text) {
                      return 'La nueva contraseña debe ser diferente';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: empleadoTextoSecundario,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: empleadoRojo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              
              final userEmail = Supabase.instance.client.auth.currentUser?.email;
              if (userEmail == null) return;

              Navigator.pop(dialogContext);
              setState(() => _loading = true);

              try {
                // 1. Verificamos la contraseña anterior reautenticando al usuario
                await Supabase.instance.client.auth.signInWithPassword(
                  email: userEmail,
                  password: passAnteriorController.text,
                );

                // 2. Si la anterior es correcta, actualizamos a la nueva contraseña
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: passNuevaController.text),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Contraseña actualizada correctamente',
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('La contraseña actual es incorrecta o falló la actualización'),
                      backgroundColor: empleadoRojo,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    passAnteriorController.dispose();
    passNuevaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final nombre = AuthHelper.obtenerNombre(user);
    final email = user?.email ?? 'correo@aylcompresores.com';

    return Scaffold(
      backgroundColor: empleadoFondo,
      drawer: const NavbarEmpleado(activeTitle: 'Mi Perfil'),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: empleadoTexto,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: empleadoTexto),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: empleadoRojo,
                strokeWidth: 2.5,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Tarjeta de Identidad Principal
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: empleadoRojo.withValues(alpha: 0.1),
                          child: Text(
                            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E',
                            style: const TextStyle(
                              color: empleadoRojo,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nombre.isNotEmpty ? nombre : 'Empleado A&L',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: empleadoTexto,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: empleadoTextoSecundario,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: empleadoRojo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'EMPLEADO ACTIVO',
                            style: TextStyle(
                              color: empleadoRojo,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contenedor de Opciones y Credenciales
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: empleadoRojo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: empleadoRojo,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: empleadoTexto,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: empleadoTextoSecundario,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                        indent: 68,
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: empleadoRojo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            color: empleadoRojo,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Estado',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: empleadoTexto,
                          ),
                        ),
                        subtitle: const Text(
                          'Sesión Supabase activa',
                          style: TextStyle(
                            fontSize: 12,
                            color: empleadoTextoSecundario,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                        indent: 68,
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: empleadoRojo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: empleadoRojo,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Contraseña',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: empleadoTexto,
                          ),
                        ),
                        subtitle: const Text(
                          'Actualiza tus credenciales',
                          style: TextStyle(
                            fontSize: 12,
                            color: empleadoTextoSecundario,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        onTap: _cambiarPassword,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}