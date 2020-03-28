import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Dog with ChangeNotifier {
  Image image;
  String name;
  DateTime bday;

  Dog.fromDog(Dog dog) {
    image = dog.image;
    name = dog.name;
    bday = dog.bday;
  }

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

  void replaceDog(int index, Dog dog) {
    dogs.removeAt(index);
    dogs.insert(index, DogCard(dog: dog));
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
              _retrieveFromAddDogPage(context, AddDogNamePage());
            },
            child: Icon(Icons.add),
            mini: true,
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        Column(
          children: dogs!=null && dogs.length!=0 ? dogs : <Widget>[Column()]
        )
      ]
    );
  }
}

class DogCard extends StatefulWidget {
  DogCard({Key key, this.dog}) : super(key: key);
  final Dog dog;

  _DogCardState createState() => _DogCardState();
}

class _DogCardState extends State<DogCard> {

  void _editDog(BuildContext context) async {
    Dog tmpDog;
    tmpDog = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDogPage(dog: widget.dog)),
    ) as Dog;
    if (tmpDog != null) {
      widget.dog.name = tmpDog.name;
      widget.dog.bday = tmpDog.bday;
      widget.dog.image = tmpDog.image;
    }
  }

  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          children: <Widget>[
            FlatButton(
              child: ListTile(
                leading: ClipRRect(child: widget.dog.image, borderRadius: BorderRadius.circular(10),),
                title: Text(widget.dog.name),
                subtitle: Text(widget.dog.bday.toString().split(' ')[0])
              ),
              onPressed: () { _editDog(context); }
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

enum _ImageSource {
  gallery,
  camera
}

class EditDogPage extends StatefulWidget {
  EditDogPage({Key key, this.dog}) : super(key: key);
  final Dog dog;
  @override
  State<EditDogPage> createState() => _EditDogPageState();
}

class _EditDogPageState extends State<EditDogPage> {
  final _formKey = GlobalKey<FormState>();
  Image image = Image(image:AssetImage('images/Goose.png'));
  String name;
  DateTime bday = DateTime.now();
  var _nameController;

  callbackImage(Image img) {
    setState(() {
      if (img != null)
        image = img;
    });
  }
  
  @override
  void initState() {
    super.initState();
    image = widget.dog.image;
    name = widget.dog.name;
    _nameController = TextEditingController(text: name);
    bday = widget.dog.bday;
  }

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit dog')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            DogImagePicker(callbackImage, widget.dog.image),
            Center(
              child: Container(
              padding: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width / 2,
              child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty)
                      return "Please enter your dog's name";
                    return null;
                  },
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                )
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 4,
              child: Column(
                children: <Widget>[
                SizedBox(height: 20.0,),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Row(
                    children: <Widget> [
                      Icon(Icons.calendar_today),
                      Padding(padding: EdgeInsets.all(4.0)),
                      Text("${bday.toLocal()}".split(' ')[0]),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  )
                )]
              )
            ),
            RaisedButton(
              onPressed: () { 
                if (_formKey.currentState.validate()) {
                  name = _nameController.text;
                  Navigator.pop(context, Dog(image, name, bday));
                }
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

class AddDogNamePage extends StatefulWidget {
  AddDogNamePage({Key key}) : super(key: key);
  _AddDogNamePageState createState() => _AddDogNamePageState();
}

class _AddDogNamePageState extends State<AddDogNamePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  String name;
  Image image;
  Dog dog;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
        title: Text('Add Dog')
        )
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Text("What's your dog's name?"),
              Form(
                key: _formKey,
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  controller: _nameController,
                  validator: (value) {
                    if (value.isEmpty)
                      return "Please enter your dog's name";
                    return null;
                  },
                )
              )
            ],
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('Next >'),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            name = _nameController.text;
            dog = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddDogImagePage(name: name)),
            ) as Dog;
            if (dog != null)
              Navigator.pop(context, dog);
            else
              Navigator.pop(context);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AddDogImagePage extends StatefulWidget {
  AddDogImagePage({Key key, this.name}) : super(key: key);
  final String name;

  _AddDogImagePageState createState() => _AddDogImagePageState();
}

class _AddDogImagePageState extends State<AddDogImagePage> {
  Image image = Image.asset('images/Goose.png');
  Dog dog;

  callbackImage(Image img) {
    setState(() {
      if (img != null)
        image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Dog'),),
      body: Center( 
        child: Column(
          children: <Widget>[
            DogImagePicker(callbackImage, image),
            Padding(
              child: Text('Choose a picture for ${widget.name}\'s profile!'),
              padding: EdgeInsets.all(30))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('Next >'),
        onPressed: () async {
          dog = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDogDatePage(name: widget.name, image: image))
          ) as Dog;
          if (dog != null)
            Navigator.pop(context, dog);
          else
            Navigator.pop(context);
        },),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AddDogDatePage extends StatefulWidget {
  AddDogDatePage({Key key, this.name, this.image}) : super(key: key);
  final String name;
  final Image image;
  @override
  _AddDogDatePageState createState() => _AddDogDatePageState();
}

class _AddDogDatePageState extends State<AddDogDatePage> {
  DateTime bday = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: bday,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year);
    if (picked != null && picked != bday) {
      setState(() {
        bday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Dog'),),
      body: Center( 
        child: Column(
          children: <Widget>[
            Padding(
              child: RaisedButton(
                onPressed: () { _selectDate(context); },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.calendar_today),
                      Text("${bday.toLocal()}".split(' ')[0]),
                    ],
                  )
                ),
              ),
              padding: EdgeInsets.all(30)
            ),
            Padding(
              child: Text('When was ${widget.name} born?'),
              padding: EdgeInsets.all(30)
            ),
            Padding(
              child: RaisedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, Dog(widget.image, widget.name, bday));
                },
              ),
              padding: EdgeInsets.all(20)
            )
          ],
        ),
      )
    );
  }
}

class DogImagePicker extends StatefulWidget {
  DogImagePicker(this.callback, this.initialImage);

  final Function(Image) callback;
  final Image initialImage;

  _DogImagePickerState createState() => _DogImagePickerState();
}

class _DogImagePickerState extends State<DogImagePicker> {
  Image image = Image.asset('images/Goose.png');

  @override
  void initState() {
    super.initState();
    image = widget.initialImage;
  }

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
      if (cropped != null) {
        image = cropped;
      }
    }
    if (image != null)
      widget.callback(image);
  }

  Widget build(BuildContext context) {
    return Container(
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