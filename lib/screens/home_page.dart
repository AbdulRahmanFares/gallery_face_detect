import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:gallery_face_detect/painters/face_painter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      color: isLoading
        ? Colors.white
        : Colors.cyan,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: isLoading
          ? null // No app bar for loading page
          : (imageFile == null)
            // App bar when no image selected yet
            ? AppBar(
              backgroundColor: Colors.cyan,
              toolbarHeight: screenHeight * 0.07,
              title: Text(
                "GALLERY FACE DETECT",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3
                )
              ),
              centerTitle: true
            )

            // App bar with the processed image
            : AppBar(
              backgroundColor: Colors.cyan,
              toolbarHeight: screenHeight * 0.07,
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => const HomePage() // Go back to home page when clicked
                  ));
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: screenWidth * 0.05
                )
              )
            ),
        body: isLoading
          // Page during image processing
          ? Center(
            // Loading screen indicator
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.cyan.shade500,
              size: screenHeight * 0.07
            )
          )
          : (imageFile == null)
            // Page for uploading an image from gallery
            ? Center(
              child: IconButton(
                onPressed: () => getGallery(),
                icon: Icon(
                  CupertinoIcons.photo,
                  size: screenHeight * 0.1,
                  color: Colors.grey
                )
              )
            )

            // Page for displaying the result of uploaded image
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

