import 'package:flutter/material.dart';

class AuthHeroWidget extends StatelessWidget {
  const AuthHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.42,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C9A7).withAlpha(230),
            const Color(0xFF00A388),
          ],
        ),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/ChatGPT_Image_Jun_30__2026__01_31_54_PM-1782807106322.png',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF00A388).withAlpha(140),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 0, left: 0),
          child: Image.asset(
            'assets/images/ChatGPT_Image_Jun_30__2026__01_15_02_PM__1_-1782807334638.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            semanticLabel: 'Jivandhara brand logo',
          ),
        ),
      ),
    );
  }
}
