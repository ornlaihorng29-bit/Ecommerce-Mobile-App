import 'package:flutter/material.dart';

class ItemAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea( // បន្ថែម SafeArea ដើម្បីការពារកុំឱ្យជាន់កាមេរ៉ា
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(25),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context); // បន្ថែមកូដនេះដើម្បីឱ្យប៊ូតុង Back ដើរ
              },
              child: Icon(
                Icons.arrow_back,
                size: 30,
                color: Color(0xFF4C53A5),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Product",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C53A5),
                ),
              ),
            ),
            Spacer(),
            Icon(
              Icons.favorite,
              size: 30,
              color: Colors.red, // ប្តូរពណ៌បេះដូងឱ្យក្រហមដូចក្នុងរូប
            ),
          ],
        ),
      ),
    );
  }
}