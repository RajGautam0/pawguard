import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? const RescueTab() : const AdoptionTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Rescue'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adoption'),
        ],
      ),
    );
  }
}

// --- RESCUE TAB (AI Diagnosis) ---
class RescueTab extends StatefulWidget {
  const RescueTab({super.key});

  @override
  State<RescueTab> createState() => _RescueTabState();
}

class _RescueTabState extends State<RescueTab> {
  File? _image;
  String _result = '';
  String _advice = '';
  bool _loading = false;

  final String apiUrl = 'http://192.168.1.69:5000/predict';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _result = '';
      _advice = '';
      _loading = true;
    });

    await _sendToApi(_image!);
  }

  Future<void> _sendToApi(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = jsonDecode(responseBody);
        setState(() {
          _result = "${data['disease']} (${(data['confidence'] * 100).toStringAsFixed(1)}% confidence)";
          _advice = data['advice'] ?? '';
          _loading = false;
        });
      } else {
        setState(() {
          _result = "Server error: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = "Connection failed. Is the Flask server running?\n$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pawguard Rescue'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 250)
            else
              Container(
                height: 250,
                color: Colors.grey.shade200,
                child: const Center(child: Text('No image selected')),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_result.isNotEmpty)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_result, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_advice.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_advice, style: const TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- ADOPTION TAB (fetches real data from MongoDB via Flask) ---
class AdoptionTab extends StatefulWidget {
  const AdoptionTab({super.key});

  @override
  State<AdoptionTab> createState() => _AdoptionTabState();
}

class _AdoptionTabState extends State<AdoptionTab> {
  final String apiUrl = 'http://192.168.1.69:5000/dogs';

  List<dynamic> _dogs = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDogs();
  }

  Future<void> _fetchDogs() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _dogs = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Server error: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Could not load dogs. Is the server running?\n$e";
        _loading = false;
      });
    }
  }

  Color _colorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'brown':
        return Colors.brown.shade300;
      case 'black':
        return Colors.black87;
      case 'orange':
        return Colors.orange.shade200;
      case 'grey':
      case 'gray':
        return Colors.grey.shade500;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pawguard Adoption'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDogs,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDogs,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _dogs.map((dog) {
                      return _buildDogCard(
                        name: dog['name'] ?? 'Unknown',
                        age: dog['age'] ?? 'Unknown',
                        gender: dog['gender'] ?? 'Unknown',
                        description: dog['description'] ?? '',
                        color: _colorFromName(dog['color'] ?? ''),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildDogCard({
    required String name,
    required String age,
    required String gender,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.pets, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Age: $age"),
                  Text("Gender: $gender"),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: const Text("Adopt Me", style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}