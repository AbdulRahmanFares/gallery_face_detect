import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:gallery_face_detect/painters/face_painter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  List<Face>? faces;
  bool isLoading = false;
  ui.Image? image;

  getGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // Ensure pickedFile is not null

    setState(() {
      imageFile = File(pickedFile.path);
      isLoading = true;
    });

    final inputImage = InputImage.fromFilePath(pickedFile.path);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    List<Face> inputImageFaces = await faceDetector.processImage(inputImage);

    setState(() {
      faces = inputImageFaces;
      loadImage(File(pickedFile.path));
    });
  }

  loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
      image = value;
      isLoading = false;
    }));
  }
  
  @override
  Widget build(BuildContext context) {

    // Device's screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ColorfulSafeArea(
      color: Colors.white,
      child: Scaffold(
        body: isLoading
          ? const Center(
            child: CircularProgressIndicator()
          )
          : (imageFile == null)
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => getGallery(),
                    icon: Icon(
                      CupertinoIcons.photo,
                      size: screenHeight * 0.1,
                      color: Colors.grey
                    )
                  ),
                  SizedBox(
                    height: screenHeight * 0.05
                  ),
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey
                      )
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "GALLERY FACE DETECT",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1
                      )
                    )
                  )
                ]
              )
            )
            : Center(
              child: FittedBox(
                child: SizedBox(
                  height: image?.height.toDouble() ?? 0,
                  width: image?.width.toDouble() ?? 0,
                  child: CustomPaint(
                    painter: image != null && faces != null
                      ? FacePainter(image!, faces!)
                      : null
                  )
                )
              )
            )
      )
    );
  }
}

