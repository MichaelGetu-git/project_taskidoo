import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetailWidget extends StatefulWidget {
  const ProfileDetailWidget({Key? key}) : super(key: key);

  @override
  _ProfileDetailWidgetState createState() => _ProfileDetailWidgetState();
}

class _ProfileDetailWidgetState extends State<ProfileDetailWidget> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isEditing = false;
  File? _profileImage;
  String? name;
  String? email;
  String? profileImageBase64;
  String? bio;
  String? phone;
  String? location;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch profile data from Firestore
  Future<void> _fetchProfileData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            name = doc.data()?['name'];
            email = doc.data()?['email'];
            profileImageBase64 = doc.data()?['profileImageBase64'];
            bio = doc.data()?['bio'];
            phone = doc.data()?['phone'];
            location = doc.data()?['location'];
            _nameController.text = name ?? '';
            _bioController.text = bio ?? '';
            _phoneController.text = phone ?? '';
            _locationController.text = location ?? '';
          });
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Save profile data including the image (Base64 string)
  Future<void> _saveProfile() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'name': _nameController.text,
          'bio': _bioController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'profileImageBase64': profileImageBase64, // Save Base64 image
        });
        setState(() {
          name = _nameController.text;
          bio = _bioController.text;
          phone = _phoneController.text;
          location = _locationController.text;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  // Pick a profile image, convert it to Base64 and save it to Firestore
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Convert the image to Base64
      final bytes = await _profileImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Save the Base64 image to Firestore
      setState(() {
        profileImageBase64 = base64Image;
      });
    }
  }

  // Convert the Base64 string to a usable image widget
  Widget _buildProfileImage() {
    if (profileImageBase64 != null) {
      final bytes = base64Decode(profileImageBase64!);
      return Image.memory(
        bytes,
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      );
    }
    return const Icon(
      Icons.person,
      size: 180,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Image Section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: GestureDetector(
                  onTap: _isEditing ? _pickProfileImage : null,
                  child: _buildProfileImage(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Name Section
            ListTile(
              title: _isEditing
                  ? TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              )
                  : Text(
                capitalize(name ?? 'No name provided'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Text(
                email ?? 'No email provided',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const Divider(),
            // Phone Section
            ListTile(
              title: const Text('Phone'),
              subtitle: _isEditing
                  ? TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              )
                  : Text(phone ?? 'No phone number provided'),
              trailing: _isEditing
                  ? IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  // You can implement additional phone validation here
                },
              )
                  : null,
            ),
            const Divider(),
            // Location Section
            ListTile(
              title: const Text('Location'),
              subtitle: _isEditing
                  ? TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              )
                  : Text(location ?? 'No location provided'),
              trailing: _isEditing
                  ? IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  // Implement location saving logic if needed
                },
              )
                  : null,
            ),
            const Divider(),
            // Bio Section
            _isEditing
                ? ListTile(
              title: const Text('Bio'),
              subtitle: TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                maxLines: 3,
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                title: const Text('Bio'),
                subtitle: Text(
                  bio ?? 'No bio added yet',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Divider(),
            // Edit Profile Button Section
            _isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Save Profile'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            )
                : Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
