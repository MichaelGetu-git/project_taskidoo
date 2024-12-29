import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // Resize the image to a smaller size and return the base64 string
  Future<String?> _resizeAndEncodeImage(File imageFile) async {
    try {
      // Read the image file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Decode the image
      img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

      // Resize the image (e.g., to 600x600 pixels)
      img.Image resizedImage = img.copyResize(image, width: 600, height: 600);

      // Encode the resized image to a byte array (JPG format)
      List<int> resizedImageBytes = img.encodeJpg(resizedImage);

      // Convert the resized image to base64
      String base64Image = base64Encode(Uint8List.fromList(resizedImageBytes));

      // Check if the base64 image exceeds Firestore size limits (1MB)
      if (base64Image.length > 1048487) {
        throw Exception("Image is too large to upload to Firestore.");
      }

      return base64Image; // Return the base64 string
    } catch (e) {
      print("Error resizing and encoding image: $e");
      return null;
    }
  }

  Future<void> _createAccount() async {
    try {
      // Validate input fields before proceeding
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required')));
        return;
      }

      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print("User registered successfully");

      User? user = userCredential.user;

      if (user != null) {
        String? profileImageBase64;

        if (_profileImage != null) {
          // Resize and encode the image
          profileImageBase64 = await _resizeAndEncodeImage(_profileImage!);
        }

        print("Saving user data to Firestore...");
        // Save user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'profileImageBase64': profileImageBase64 ?? '', // Save empty string if no image
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("User data saved to Firestore");

        // Navigate to home page
        Navigator.pushNamed(context, '/home-page');
      }
    } catch (e) {
      print("Error during account creation: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Creation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: _profileImage != null
                  ? CircleAvatar(
                radius: 95,
                backgroundImage: FileImage(_profileImage!),
                backgroundColor: Colors.grey[200],
              )
                  : CircleAvatar(
                radius: 95,
                backgroundColor: Colors.grey[850],
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(40.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Enter your name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Account',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // Mask password input
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 17.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
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
