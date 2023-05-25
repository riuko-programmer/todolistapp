// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTF {
  static Widget textField(String title,
      {bool isPassword = false,
      bool isNumber = false,
      String hintText = '',
      bool isEnable = true,
      int length = 100,
      TextEditingController? textController,
      int lines = 1,
      Color inputColor = Colors.black}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            maxLines: lines,
            controller: textController,
            maxLength: length,
            enabled: isEnable,
            inputFormatters: [
              LengthLimitingTextInputFormatter(length),
            ],
            obscureText: isPassword,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: inputColor),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              suffix: isPassword
                  ? InkWell(
                      onTap: () {},
                      child: const Text("CHANGE",
                          style: TextStyle(
                              color: Color(0xffFA9955), fontSize: 12)),
                    )
                  : null,
            ),
          )
        ],
      ),
    );
  }

  static Widget fullNameTextField(String title,
      {bool isPassword = false,
      bool isNumber = false,
      int length = 100,
      String hintText1 = "",
      String hintText2 = "",
      TextEditingController? textController,
      TextEditingController? textController2,
      int lines = 1,
      Color inputColor = Colors.black}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  maxLines: lines,
                  controller: textController,
                  maxLength: length,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(length),
                  ],
                  decoration: InputDecoration(
                    hintText: hintText1,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  maxLines: lines,
                  controller: textController2,
                  maxLength: length,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(length),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: hintText2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
