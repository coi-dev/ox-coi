import 'dart:io';

import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String imagePath;
  final String initials;
  final Color color;

  Avatar({this.imagePath, @required this.initials, this.color});

  @override
  Widget build(BuildContext context) {
    FileImage avatarImage;
    if (imagePath != null && imagePath.isNotEmpty) {
      avatarImage = FileImage(File(imagePath));
    }
    return CircleAvatar(
      radius: 24,
      foregroundColor: Colors.white,
      backgroundColor: color != null ? color : Colors.blue[700],
      child: avatarImage != null ? avatarImage : showInitials(),
    );
  }

  Text showInitials() {
    return new Text(initials);
  }
}
