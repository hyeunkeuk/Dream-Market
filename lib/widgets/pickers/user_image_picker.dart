import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _storedImage;
  void _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    setState(() {
      _storedImage = File(imageFile.path);
    });
    widget.imagePickFn(_storedImage);

    // final appDir = await syspaths.getApplicationDocumentsDirectory();
    // final fileName = path.basename(imageFile.path);
    // final savedImage = await _storedImage.copy('${appDir.path}/$fileName');
  }

  Future<void> _getPicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 200,
          height: 200,
          margin: EdgeInsets.only(
            top: 8,
            right: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _storedImage == null
              ? Text('No Image', textAlign: TextAlign.center)
              : Image.file(_storedImage),
          alignment: Alignment.center,
        ),
        Column(
          children: [
            Container(
              child: FlatButton.icon(
                icon: Icon(Icons.add_a_photo),
                label: Text('Take Picture'),
                textColor: Theme.of(context).primaryColor,
                onPressed: _takePicture,
              ),
            ),
            Container(
              child: FlatButton.icon(
                icon: Icon(Icons.add_photo_alternate),
                label: Text('From Gallery'),
                textColor: Theme.of(context).primaryColor,
                onPressed: _getPicture,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
