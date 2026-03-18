import 'dart:convert'; // ✅ FIX: necesario para json.decode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ✅ FIX: para consumir la API

void main() => runApp(const DogApp());

class DogApp extends StatelessWidget {
  const DogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DogHomePage(),
    ); // ✅ FIX: paréntesis/llaves correctas
  }
}

class DogHomePage extends StatefulWidget {
  const DogHomePage({super.key});

  @override
  State<DogHomePage> createState() => _DogHomePageState();
} // ✅ FIX: quitada llave extra

class _DogHomePageState extends State<DogHomePage> {
  String? imageUrl;
  bool isLoading = false; // ✅ FIX: bool, no String?

  // ✅ FIX: función completa con try/catch/finally y setState correctos
  Future<void> fetchRandomDog() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/image/random'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          imageUrl = data['message'] as String?;
        });
      } else {
        // Manejo simple de error por status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error HTTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Manejo de errores de red / parsing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Dog API'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl!,
                    height: 280,
                    fit: BoxFit.cover,
                    // ✅ tip: por si falla la imagen
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('No se pudo cargar la imagen.'),
                  ),
                )
              else
                const Text('Presiona el botón para cargar un perrito 🐶'),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : fetchRandomDog,
                child: const Text('Traer perrito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
