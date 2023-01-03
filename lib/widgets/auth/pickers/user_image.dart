import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final void Function(File pickedImage) imagePickFn;
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile _pickedImage;
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedImageFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(File(pickedImageFile.path));
  }

  void _getImage() async {
    final pickedImageFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(File(pickedImageFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundImage:
              _pickedImage != null ? FileImage(File(_pickedImage.path)) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.add_a_photo, size: 20),
              label: Text(
                'Camera',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _getImage,
              icon: Icon(Icons.add_a_photo_rounded, size: 20),
              label: Text(
                'Library',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
