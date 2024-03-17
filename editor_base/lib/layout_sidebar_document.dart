import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({Key? key}) : super(key: key);

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
  ValueNotifier(const Color(0x800080FF));

  @override
  Widget build(BuildContext context) {
    _preloadedColorPicker = _buildPreloadedColorPicker();
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;
    Color backgroundColor = theme.backgroundSecondary2;

    TextStyle fontBold =
    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Document properties:", style: fontBold),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Width:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 80,
                    child: CDKFieldNumeric(
                      value: appData.docSize.width,
                      min: 1,
                      max: 2500,
                      units: "px",
                      increment: 100,
                      decimals: 0,
                      onValueChanged: (value) {
                        appData.setDocWidth(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Height:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 80,
                    child: CDKFieldNumeric(
                      value: appData.docSize.height,
                      min: 1,
                      max: 2500,
                      units: "px",
                      increment: 100,
                      decimals: 0,
                      onValueChanged: (value) {
                        appData.setDocHeight(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Background color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  CDKButtonColor(
                    key: _anchorColorButton,
                    color: _valueColorNotifier.value,
                    onPressed: () {
                      _showPopoverColor(context, _anchorColorButton);
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 16),
              Text("File actions:", style: fontBold),
              SizedBox(height: 8),
              Row(
                children: [
                  CupertinoButton.filled(
                    minSize: 0,
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () {
                      // Acción al cargar el archivo
                    },
                    child: Text("Load"),
                  ),
                  SizedBox(width: 8),
                  CupertinoButton.filled(
                    minSize: 0,
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () {
                      _saveSvgFile(appData);
                    },
                    child: Text("Export"),
                  ),
                  SizedBox(width: 8),
                  CupertinoButton.filled(
                    minSize: 0,
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () {
                      // Acción para exportar como SVG
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPopoverColor(BuildContext context, GlobalKey anchorKey) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
    if (anchorKey.currentContext == null) {
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
      key: key,
      context: context,
      anchorKey: anchorKey,
      isAnimated: true,
      isTranslucent: false,
      onHide: () {},
      child: _preloadedColorPicker,
    );
  }

  Widget _buildPreloadedColorPicker() {
    AppData appData = Provider.of<AppData>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          return CDKPickerColor(
            color: value,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                appData.setBackgroundColor(color);
              });
            },
          );
        },
      ),
    );
  }

  void _saveSvgFile(AppData appdata) {
    String svgContent = _generateSvgContent(appdata);
    Directory documentsDirectory = Directory.current;
    String filePath = '${documentsDirectory.path}/drawing.svg';
    File svgFile = File(filePath);
    svgFile.writeAsStringSync(svgContent);
    print('SVG file saved at: $filePath');
  }

  String _generateSvgContent(AppData appData) {
    // Inicializa el contenido SVG con la etiqueta raíz
    StringBuffer svgContent = StringBuffer();
    svgContent.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    svgContent.writeln(
      '<svg width="${appData.docSize.width}" height="${appData.docSize.height}" xmlns="http://www.w3.org/2000/svg">',
    );

    // Itera sobre la lista de formas dibujadas y agrega elementos SVG correspondientes
    for (var shape in appData.shapesList) {
      if (shape.vertices.isNotEmpty) {
        // Comienza un nuevo elemento SVG para la forma
        svgContent.writeln('<path');

        // Agrega atributos SVG para describir la forma (por ejemplo, coordenadas, color, etc.)
        svgContent.writeln(
          ' d="M ${shape.vertices[0].dx},${shape.vertices[0].dy}',
        );
        for (int i = 1; i < shape.vertices.length; i++) {
          svgContent.writeln(
            ' L ${shape.vertices[i].dx},${shape.vertices[i].dy}',
          );
        }
        if (shape.closed) {
          svgContent.writeln(' Z"');
        } else {
          svgContent.writeln('"');
        }
        svgContent.writeln(' fill="${shape.fillColor}"');
        svgContent.writeln(' stroke="${shape.color}"');
        svgContent.writeln(' stroke-width="${shape.stroke}"');

        // Cierra el elemento SVG
        svgContent.writeln(' />');
      }
    }

    // Cierra la etiqueta SVG raíz
    svgContent.writeln('</svg>');

    return svgContent.toString();
  }


}
