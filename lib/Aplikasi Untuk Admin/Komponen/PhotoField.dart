import 'package:flutter/material.dart';

import '../../komponen/style.dart';

class PhotoField extends StatelessWidget {
  const PhotoField({
    Key? key,
    required this.controller,
    this.selectedPhotoName = '',
    required this.onPressed,
  }) : super(key: key);

  final TextEditingController controller;
  final String selectedPhotoName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 30,
                  color: Warna.white,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: selectedPhotoName.isNotEmpty
                      ? 'Selected Image:'
                      : 'Select an Image',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.0,
                      color: Warna.grey,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.0,
                      color: Warna.grey,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.0,
                      color: Warna.grey,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Text(
                  selectedPhotoName.isNotEmpty
                      ? '$selectedPhotoName'
                      : '',
                  style: TextStyles.body.copyWith(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
