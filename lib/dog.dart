import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DogPage extends StatefulWidget {
  DogPage({Key key}) : super(key: key);
  
  @override
  _DogPageState createState() => _DogPageState();
}

class _DogPageState extends State<DogPage> {
  List<DogCard> dogs = <DogCard>[];

  void addDog(String name, String bday) {
    dogs.add(DogCard(name: name, bday: bday));
  }

  void removeDog(int index) {
    dogs.removeAt(index);
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            FloatingActionButton(
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDogPage()),
              );
            },
            child: Icon(Icons.add),
            mini: true,
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        Column(
          children: dogs!=null&&dogs.length!=0 ? dogs : <Widget>[Column()]
        )
      ]
    );
  }
}

class DogCard extends StatefulWidget {
  DogCard({Key key, this.name, this.bday}) : super(key: key);

  final String name;
  final String bday;

  @override
  State<StatefulWidget> createState() => _DogCardState();
}

class _DogCardState extends State<DogCard> {
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Image(image: AssetImage('images/Goose.png')),
              title: Text(widget.name),
              subtitle: Text(widget.bday)
            )
          ]
        ),
        color: Colors.blueGrey[200],
        shape: RoundedRectangleBorder(),
        margin: EdgeInsets.all(4.0)
      )
    );
  }
}

class AddDogPage extends StatefulWidget {
  AddDogPage({Key key}) : super(key: key);
  
  @override
  State<AddDogPage> createState() => _AddDogPageState();
}

class _AddDogPageState extends State<AddDogPage> {
  final _formKey = GlobalKey<FormState>();
  String name;
  DateTime bday = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: bday,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year);
    if (picked != null && picked != bday)
    setState(() {
      bday = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add dog')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
              Container(
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: FlatButton(
                      child: ClipRRect(
                        child: Image(image:AssetImage('images/Goose.png')),
                        borderRadius: BorderRadius.circular(12.0),
                      ), 
                      onPressed: () =>
                        Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => CameraDogPage(),
                            settings: RouteSettings(name: 'AddDogPage'))
                        )
                    )
                  ),
                width: MediaQuery.of(context).size.width / 2
              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter your dog's name";
                  }
                  return null;
                },
                textAlign: TextAlign.center,
              )
            ),
            Container(
              height: MediaQuery.of(context).size.height / 4,
              child: Column(
                children: <Widget>[
                SizedBox(height: 20.0,),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Text("${bday.toLocal()}".split(' ')[0]),
                )]
              )
            ),
            RaisedButton(
              onPressed: () { Navigator.pop(context); },
              child: Text('OK')
            )
          ],
        )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class CameraDogPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraDogPageState();
}

class _CameraDogPageState extends State<CameraDogPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  var imagePath;
  @override
  void initState() {
    super.initState();
    _initializeCamera(); 
  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.length == 0)
      return;
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera,ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted)
      return;
    setState(() {
      isCameraReady = true;
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _controller != null) {
      _initializeControllerFuture = _controller.initialize();
      //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }

  void onCaptureButtonPressed(BuildContext context) async {  //on camera button press
    try {
      final path = join(
        (await getTemporaryDirectory()).path, //Temporary path
          '${DateTime.now()}.png',
      );
      imagePath = path;
      await _controller.takePicture(path); //take photo
      setState(() {
        showCapturedPhoto = true;
        Navigator.push(context, 
          MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: imagePath)));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final size = MediaQuery.of(context).size;
          final deviceRatio = size.width / size.height;
          // If the Future is complete, display the preview.
          return Transform.scale(
            scale: _controller.value.aspectRatio / deviceRatio,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller), //cameraPreview
              ),
            ));
          } else {
            return Center(
              child: CircularProgressIndicator()
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => onCaptureButtonPressed(context),
        child: Icon(Icons.camera)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Image.file(File(imagePath)),
      floatingActionButton:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () { Navigator.pop(context); },
              child: Icon(Icons.cancel),
              heroTag: 0,
              backgroundColor: Colors.red,),
            Padding(padding: EdgeInsets.all(12.0),),
            FloatingActionButton(
              onPressed: () { Navigator.pop(context); },
              child: Icon(Icons.check),
              heroTag: 1,
              backgroundColor: Colors.green)
          ]
        ),
    );
  }
}