// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuli/CustomWidget.dart';
import 'package:nuli/dataclass.dart' as dataclass;
import 'package:nuli/dbservices.dart';

class EditProfile extends StatefulWidget {
  final dataclass.User user;
  const EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late XFile? image;
  bool imageChanged = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorText = "Please fill all the fields";

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    String firstName = widget.user.fullname.split(' ')[0];
    String lastName = widget.user.fullname.split(' ').length > 1
        ? widget.user.fullname.substring(widget.user.fullname.indexOf(' ') + 1)
        : '';
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    _emailController.text = widget.user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Row(
                children: const [
                  Icon(Icons.arrow_back_ios, color: Colors.grey),
                  Text("Back", style: TextStyle(color: Colors.grey)),
                ],
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Text("Edit Profile", style: TextStyle(color: Colors.black)),
            const SizedBox(),
            const SizedBox()
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: imageChanged
                          ? FileImage(File(image!.path)) as ImageProvider
                          : NetworkImage(widget.user.photoUrl),
                      backgroundColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: ElevatedButton(
                        onPressed: () async {
                          XFile? newimage = await _imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (newimage != null) {
                            setState(() {
                              image = newimage;
                              imageChanged = true;
                            });
                          }
                        },
                        child: const Icon(Icons.edit),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(10)),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xff1C549D)), // <-- Button color
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xffF27470);
                              }
                              return null; // <-- Splash color
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTF.textField("Email address",
                  inputColor: Colors.red,
                  textController: _emailController,
                  isEnable: false),
              const SizedBox(height: 10),
              CustomTF.fullNameTextField("Full name",
                  inputColor: Colors.yellow,
                  textController: _firstNameController,
                  textController2: _lastNameController,
                  hintText1: "First name",
                  hintText2: "Last name"),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      maxLines: 1,
                      controller: _passwordController,
                      maxLength: 100,
                      enabled: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "********",
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.yellow),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        suffix: InkWell(
                          onTap: () {
                            openDialog();
                          },
                          child: const Text("CHANGE",
                              style: TextStyle(
                                  color: Color(0xffFA9955), fontSize: 12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff1C549D), Color(0xff3392DC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(30)),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 100,
                    shadowColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    await UserService.verifyPassword(
                            _emailController.text, _passwordController.text)
                        .then(
                      (value) async {
                        if (value == true) {
                          String imageUrl = '';
                          if (imageChanged) {
                            imageUrl =
                                await UserService.uploadImage(image!.path);
                          }
                          await UserService.updateUserToFirestore(
                            user: dataclass.User(
                                email: _emailController.text,
                                fullname:
                                    "${_firstNameController.text} ${_lastNameController.text}",
                                uid: widget.user.uid,
                                photoUrl: imageUrl == ''
                                    ? widget.user.photoUrl
                                    : imageUrl),
                          )
                              .whenComplete(() =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "User profile updated successfully"),
                                    ),
                                  ))
                              .catchError(
                                (e) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Error occured while updating profile"),
                                  ),
                                ),
                              );
                          setState(() {});
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password is invalid or empty"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.5), width: 2)),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5), fontSize: 18),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 100,
                    shadowColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (BuildContext dialogcontext) =>
            StatefulBuilder(builder: (dialogcontext, setState) {
          return AlertDialog(
            title: const Text("Change Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_errorText,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Old Password",
                      hintText: "********",
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      hintText: "********",
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "********",
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(dialogcontext);
                },
              ),
              ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async {
                  await UserService.verifyPassword(
                          _emailController.text, _oldPasswordController.text)
                      .then(
                    (value) async {
                      if (value == true &&
                          _newPasswordController.text ==
                              _confirmPasswordController.text) {
                        bool result = await UserService.updatePassword(
                            _emailController.text, _newPasswordController.text);

                        if (result) {
                          Navigator.pop(dialogcontext);
                          ScaffoldMessenger.of(dialogcontext).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("User password updated successfully"),
                            ),
                          );
                        } else {
                          Navigator.pop(dialogcontext);
                          return ScaffoldMessenger.of(dialogcontext)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Error occured while updating password"),
                            ),
                          );
                        }
                        setState(() {});
                      } else {
                        setState(() {
                          _errorText = "Password is invalid or empty";
                        });
                      }
                    },
                  );
                },
              ),
            ],
          );
        }),
      );
}
