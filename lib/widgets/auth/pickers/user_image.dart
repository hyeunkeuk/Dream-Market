import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart' as syspaths;

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  UserImagePicker(this.imagePickFn);
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  final picker = ImagePicker();

  void _pickImage() async {
    final pickedImageFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });
    widget.imagePickFn(_pickedImage);
  }

  Future<void> _getImage() async {
    final pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      // maxWidth: 150,
      // maxWidth: 600,
    );
    if (_pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(_pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage) : null,
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
              onPressed: () {
                _getImage();
              },
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
