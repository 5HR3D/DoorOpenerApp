import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raspberry_pi_door_opener/utils/localizations/app_localizations.dart';
import 'package:raspberry_pi_door_opener/utils/other/data_manager.dart';
import 'package:raspberry_pi_door_opener/utils/security/key_manager.dart';
import 'package:screenshot/screenshot.dart';

import '../constants.dart';

class ShareCredentials extends StatefulWidget {
  static const routeName = 'share-credentials';

  @override
  _ShareCredentialsState createState() => _ShareCredentialsState();
}

class _ShareCredentialsState extends State<ShareCredentials> {
  bool loaded = false;
  String payload;
  ScreenshotController screenshot = ScreenshotController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    KeyManager keyManager = KeyManager();
    String tempKey = await keyManager.hexKey;
    String tempPassword = await KeyManager().hexPassword;
    Nonce nonce = await keyManager.passwordNonce;
    String ipAddress = await DataManager.ipAddress;
    int port = await DataManager.port;
    int time = await DataManager.time;
    String passwordNonce = hex.encode(nonce.bytes);
    payload = '$tempKey;$tempPassword;$passwordNonce;$ipAddress;$port;$time';
    print('payload: $payload');
    setState(() {
      print('rdy');
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding / 2),
          child: Container(
            child: Center(
              child: loaded
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            height: 200,
                            width: 200,
                            margin: EdgeInsets.fromLTRB(50, 50, 50, 50),
                            child: Screenshot(
                              controller: screenshot,
                              child: QrImage(
                                data: payload,
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            DataManager.takeScreenShot(
                              screenshot,
                              AppLocalizations.of(context).translate(
                                "share_credentials_share_qr",
                              ),
                            );
                          },
                          icon: Icon(
                            CupertinoIcons.share,
                            color: Colors.white,
                          ),
                          label: Text('Share'),
                        ),
                      ],
                    )
                  : Text('pls wait a moment'),
            ),
          ),
        ),
      ),
    );
  }
}
