import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Dog with ChangeNotifier {
  Image image;
  String name;
  DateTime bday;

  Dog(Image i, String n, DateTime b) {
    image = i; name = n; bday = b;
  }
}

class DogPage extends StatefulWidget {
  DogPage({Key key}) : super(key: key);
  
  @override
  _DogPageState createState() => _DogPageState();
}

class _DogPageState extends State<DogPage> {
  List<DogCard> dogs = <DogCard>[];

  void _retrieveFromAddDogPage(BuildContext context, Widget page) async {
    final dog = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
    ) as Dog;
    if (dog != null)
      dogs.add(DogCard(dog: dog));
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
              _retrieveFromAddDogPage(context, AddDogPage());
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

class DogCard extends StatelessWidget {
  DogCard({Key key, this.dog}) : super(key: key);

  final Dog dog;

  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: ClipRRect(child: dog.image, borderRadius: BorderRadius.circular(10),),
              title: Text(dog.name),
              subtitle: Text(dog.bday.toString().split(' ')[0])
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

enum _ImageSource {
  gallery,
  camera
}

class _AddDogPageState extends State<AddDogPage> {
  final _formKey = GlobalKey<FormState>();
  Image image = Image(image:AssetImage('images/Goose.png'));
  String name;
  DateTime bday = DateTime.now();
  final _nameController = TextEditingController();

  void _retrieveImage(BuildContext context, _ImageSource source) async {
    File img;
    if (source == _ImageSource.camera)
      img = await ImagePicker.pickImage(source: ImageSource.camera);
    else if (source == _ImageSource.gallery)
      img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      final cropped = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CropPictureScreen(imageFile: img.path)),
      ) as Image;
      setState(() {
        if (cropped != null)
          image = cropped;
      });
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: bday,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year);
    if (picked != null && picked != bday)
      bday = picked;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                    child: PopupMenuButton<_ImageSource>(
                      child: ClipRRect(
                        child: image,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      onSelected: (_ImageSource img) => _retrieveImage(context, img),
                      itemBuilder: (BuildContext context) => <PopupMenuItem<_ImageSource> >[
                        const PopupMenuItem<_ImageSource>(
                          value: _ImageSource.gallery,
                          child: Text('Choose an image from gallery'),
                        ),
                        const PopupMenuItem<_ImageSource>(
                          value: _ImageSource.camera,
                          child: Text('Take a picture'),
                        ),
                      ]
                    )
                  ),
                width: MediaQuery.of(context).size.width / 2
              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty)
                    return "Please enter your dog's name";
                  return null;
                },
                controller: _nameController,
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
              onPressed: () { 
                _formKey.currentState.validate();
                name = _nameController.text;
                Navigator.pop(context, Dog(image, name, bday));
              },
              child: Text('OK')
            )
          ],
        )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class CropPictureScreen extends StatefulWidget {
  CropPictureScreen({Key key, this.imageFile}) : super(key: key);
  final String imageFile;

  State<StatefulWidget> createState() => _CropPictureScreenState();
}

class _CropPictureScreenState extends State<CropPictureScreen> {
  File cropped;

  Future<Null> _cropImage(context) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: widget.imageFile,
      aspectRatio: CropAspectRatio(ratioY: 1.0, ratioX: 1.0),
      aspectRatioPresets: [
        CropAspectRatioPreset.square
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop the picture',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
        title: 'Crop the picture',
        resetAspectRatioEnabled: false,
        aspectRatioPickerButtonHidden: true
      )
    );
    if (croppedFile != null && await croppedFile.exists()) {
      cropped = croppedFile;
      Navigator.pop(context, Image.file(cropped));
    }
    else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<void>(
        future: _cropImage(context),
        builder: (context, snapshot) {
          return Center(
            child: CircularProgressIndicator()
          );
        }
      ),
      backgroundColor: Colors.black,
    );
  }
}