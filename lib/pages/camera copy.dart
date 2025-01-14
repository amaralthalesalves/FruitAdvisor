import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:fruitadvisor/colors.dart'; // Import your colors
import 'package:fruitadvisor/pages/fruitview.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    } else {
      Navigator.pop(context); // Close the page if no image is picked
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-api-endpoint.com/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      final fruitName = responseData['column_name'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem enviada com sucesso')),
      );

      // Navigate to FruitView page with the fruit name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FruitView(fruitName: fruitName),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar a imagem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _image == null
            ? CircularProgressIndicator()
            : Image.file(_image!),
      ),
    );
  }
}