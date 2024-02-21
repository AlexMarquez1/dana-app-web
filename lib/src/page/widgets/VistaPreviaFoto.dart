import 'dart:typed_data';

import 'package:flutter/material.dart';

class VistaPreviaFoto extends StatelessWidget {
  String urlImagen;
  Uint8List? bytes;
  VistaPreviaFoto({
    Key? key,
    this.bytes,
    required this.urlImagen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  urlImagen.isNotEmpty
                      ? Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 50.0),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/img/loadingImage.gif',
                            image: urlImagen,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 50.0),
                          child: Image.memory(bytes!),
                        ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: 100.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          Text(
                            ' Cerrar',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
