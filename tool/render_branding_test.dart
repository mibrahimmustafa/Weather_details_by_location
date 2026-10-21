// Renders the Ajwaa brand assets (app icon, adaptive foreground, monochrome
// mask and splash logo) to `assets/branding/`.
//
// Run with:
//   flutter test tool/render_branding_test.dart
//
// This file lives outside `test/` on purpose so it is not part of the regular
// unit-test suite; it is a build step for the branding PNGs.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ajwaa/presentation/widgets/ajwaa_logo.dart';

const _background = Color(0xFF0B1B33);

Future<Uint8List> _capture(
  WidgetTester tester,
  Widget child, {
  required double size,
  Color? background,
}) async {
  tester.view.physicalSize = Size(size, size);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: Container(
          width: size,
          height: size,
          color: background,
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();

  final bytes = await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

Future<void> _write(String name, Uint8List bytes) async {
  final dir = Directory('assets/branding');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  File('assets/branding/$name').writeAsBytesSync(bytes);
}

void main() {
  testWidgets('renders branding assets', (tester) async {
    // Full-bleed app icon used for legacy Android, iOS and the web favicon.
    await _write(
      'app_icon.png',
      await _capture(tester, const AjwaaAppIcon(size: 1024), size: 1024),
    );

    // Adaptive-icon foreground: transparent, mark kept inside the 66% safe
    // zone so no launcher mask clips it.
    await _write(
      'app_icon_foreground.png',
      await _capture(
        tester,
        Center(child: AjwaaMark(size: 1024 * 0.62)),
        size: 1024,
      ),
    );

    // Themed (monochrome) mask: white silhouette on transparency.
    await _write(
      'app_icon_monochrome.png',
      await _capture(
        tester,
        Center(child: AjwaaMark(size: 1024 * 0.62, monochrome: true)),
        size: 1024,
      ),
    );

    // Splash logo: drawn over the splash background colour.
    await _write(
      'splash_logo.png',
      await _capture(
        tester,
        Center(
          child: Container(
            width: 768,
            height: 768,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16345C), _background, Color(0xFF072C33)],
              ),
            ),
            child: Center(child: AjwaaMark(size: 768 * 0.62)),
          ),
        ),
        size: 1024,
      ),
    );

    // Transparent brand mark: used by the web first-paint loader and anywhere a
    // logo is needed without the icon tile behind it.
    final mark = await _capture(
      tester,
      Center(child: AjwaaMark(size: 1024 * 0.86)),
      size: 1024,
    );
    await _write('brand_mark.png', mark);
    File('web/branding-mark.png').writeAsBytesSync(mark);

    await tester.pumpWidget(const SizedBox());
  });
}
