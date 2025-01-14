import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

      // Navigate directly to FruitView page with the hardcoded fruit name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FruitView(fruitName: "apple"), // Hardcoded fruitName
        ),
      );
    } else {
      Navigator.pop(context); // Close the page if no image is picked
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
