import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../badge.dart';

class ProductImagePicker extends StatefulWidget {
  final void Function(List<File> pickedImage) imagePickFn;
  final List<String> previousImageList;

  ProductImagePicker(this.imagePickFn, this.previousImageList);

  @override
  _ProductImagePickerState createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  File _storedImage;
  List<File> _listImage = [];
  final picker = ImagePicker();
  bool _isLoading = false;
  int mainImage = 0;

  @override
  void initState() {
    // TODO: implement initState
    fetchImages();

    super.initState();
  }

  void fetchImages() async {
    // print(widget.previousImageList);
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    if (widget.previousImageList.isNotEmpty) {
      // print('hi');
      for (var i = 0; i < widget.previousImageList.length; i++) {
        if (widget.previousImageList[i] != null &&
            widget.previousImageList[i].length > 0) {
          // print(widget.previousImageList[i].length);
          var imageFile = await _fileFromImageUrl(widget.previousImageList[i]);
          // print(widget.previousImageList[i]);
          // print(imageFile);
          if (mounted) {
            setState(() {
              _listImage.add(imageFile);
              // print(_listImage);
            });
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    widget.imagePickFn(_listImage);
  }

  Future<File> _fileFromImageUrl(url) async {
    var response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    // print(documentDirectory);
    final file = File(join(documentDirectory.path, '${url.hashCode}.jpg'));

    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }

  void _takePicture() async {
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (mounted) {
      setState(() {
        _storedImage = File(imageFile.path);
        _listImage.insert(0, _storedImage);
      });
    }
    widget.imagePickFn(_listImage);
  }

  Future<void> _getPicture() async {
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (mounted) {
      setState(() {
        _storedImage = File(imageFile.path);
        _listImage.insert(0, _storedImage);
        // print(_listImage);
      });
    }
    widget.imagePickFn(_listImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Upload Images (Maximum 9)',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        GridView.builder(
          shrinkWrap: true,
          itemCount: _listImage.length + 1,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (ctx, index) {
            if (_listImage.length > 8) {
              if (index != 9) {
                return GestureDetector(
                  onTap: () {
                    print('hi');
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        // title: Text(
                        //   'Are you sure?',
                        // ),
                        // content: Text(
                        //   'Do you want to remove the item from your products?',
                        // ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Set as a Main Image'),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                              setState(() {
                                mainImage = index;
                                _listImage.insert(0, _listImage[index]);
                                _listImage.removeAt(index + 1);
                              });
                            },
                          ),
                          TextButton(
                            child: Text('Delete Image'),
                            onPressed: () async {
                              Navigator.of(ctx).pop(false);
                              setState(() {
                                _listImage.removeAt(index);
                              });
                            },
                          ),
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Badge(
                    size: 13,
                    color: Colors.white,
                    value: 'X',
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(_listImage[index])),
                        border: index == 0
                            ? Border.all(width: 5, color: Colors.blueAccent)
                            : Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            } else {
              return index == 0
                  ? Center(
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _getPicture();
                        },
                      ),
                    )
                  : _isLoading == false
                      ? GestureDetector(
                          onTap: () {
                            print('hi');
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                // title: Text(
                                //   'Are you sure?',
                                // ),
                                // content: Text(
                                //   'Do you want to remove the item from your products?',
                                // ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Set as a Main Image'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                      setState(() {
                                        mainImage = index - 1;
                                        _listImage.insert(
                                            0, _listImage[index - 1]);
                                        _listImage.removeAt(index);
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Delete Image'),
                                    onPressed: () async {
                                      Navigator.of(ctx).pop(false);
                                      setState(() {
                                        _listImage.removeAt(index - 1);
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Badge(
                            size: 13,
                            color: Colors.white,
                            value: 'X',
                            child: Container(
                              width: 200,
                              height: 200,
                              margin: EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: FileImage(_listImage[index - 1])),
                                border: index - 1 == 0
                                    ? Border.all(
                                        width: 5, color: Colors.blueAccent)
                                    : Border.all(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                              ),
                              // child: _storedImage == null
                              //     ? Text('No Image', textAlign: TextAlign.center)
                              //     : Image.file(_storedImage),
                              alignment: Alignment.center,
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
            }
          },
        ),
      ],
    );
  }
}
