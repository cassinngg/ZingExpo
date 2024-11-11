import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

//butngan ? sa tumoy for null safety
//import camera package
List<CameraDescription>? cameras;

class Identify extends StatefulWidget {
  const Identify({super.key});

  @override
  State<Identify> createState() => _IdentifyState();
}

class _IdentifyState extends State<Identify> {
  //define camera image
  //frame recorded by camera
  CameraImage? cameraImage;
  //camera controller define
  CameraController? cameraController;
  //output
  String output = '';

  @override
  void initState() {
    super.initState();
    //call loadcamera function
    //first functions to run in the app
    loadCamera();
    loadModel();
  }

  //define load function loadcamera
  loadCamera() {
    // assign camera cotroller

    //define description and resolution
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    //initialize camera controlller
    cameraController!.initialize().then((value) {
      //check if camera is mounted return nothing
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage = imageStream;
            runModel();
          });
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      //map plane
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        //boundary
        threshold: 0.1,
        asynch: true,
      );
      //prediction loop,
      predictions!.forEach((element) {
        setState(() {
          output = element['label'];
        });
      });
    }
  }

//loadmodel function
  loadModel() async {
    await Tflite.loadModel(
        model: "lib/model.tflite",
        //define label
        labels: "lib/labels.txt");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zingiberaceae Flower Identification"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                //check if camera controller is initialize,
                child: !cameraController!.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(cameraController!),
                      )),
          ),
          Text(
            output,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          )
        ],
      ),
    );
  }
}
