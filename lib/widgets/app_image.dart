import 'package:flutter/material.dart';

Widget smartImage(
  String src, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (src.isEmpty) {
    return Builder(
      builder: (context) {
        if (errorBuilder != null) {
          return errorBuilder(context, 'Gambar tidak tersedia', null);
        }
        return SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(
            color: Color(0xFFF0F3F1),
            child: Icon(Icons.image_outlined, color: Colors.grey),
          ),
        );
      },
    );
  }

  if (src.startsWith('http://') || src.startsWith('https://')) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(
            color: Color(0xFFF0F3F1),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  return Image.asset(
    src,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
