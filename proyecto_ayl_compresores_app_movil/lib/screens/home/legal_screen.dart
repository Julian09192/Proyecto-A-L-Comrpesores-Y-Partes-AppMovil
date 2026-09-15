import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final String titulo;
  final String contenido;

  const LegalScreen({super.key, required this.titulo, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(titulo, style: const TextStyle(color: Color(0xFF1E242B), fontWeight: FontWeight.w900, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E242B)), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(20)),
              child: const Text('Última actualización: Septiembre 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 24),
            Text(
              contenido,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A), height: 1.7),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}