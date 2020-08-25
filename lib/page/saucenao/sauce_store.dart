/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/document_plugin.dart';
part 'sauce_store.g.dart';

class SauceStore = SauceStoreBase with _$SauceStore;

abstract class SauceStoreBase with Store {
  Dio dio = Dio(BaseOptions(baseUrl: "https://saucenao.com"));
  ObservableList<int> results = ObservableList();
  StreamController _streamController;
  ObservableStream observableStream;
  @observable
  bool notStart = true;

  SauceStoreBase() {
    _streamController = StreamController();
    observableStream =
        ObservableStream(_streamController.stream.asBroadcastStream());
  }

  @override
  void dispose() async {
    await _streamController?.close();
  }

  Future findImage({String path}) async {
    notStart = false;
    results.clear();
    MultipartFile multipartFile;
    if (path == null) {
      Uint8List uint8list = await DocumentPlugin.pickFile();
      if (uint8list != null) {
        path =
            "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        File(path).writeAsBytesSync(uint8list);
      }
    }
    if (path == null) return;
    var formData = FormData();
    formData.files.addAll([
      MapEntry(
        "file",
        multipartFile ?? MultipartFile.fromFileSync(path),
      ),
    ]);
    try {
      BotToast.showText(text: "uploading");
      Response response = await dio.post('/search.php', data: formData);
      BotToast.showText(text: "parsing");
      var document = parse(response.data);
      document.querySelectorAll('a').forEach((element) {
        var link = element.attributes['href'];
        if (link != null) {
          bool need = link.startsWith('https://www.pixiv.net') &&
              link.contains('illust_id');
          if (need) {
            var result = Uri.parse(link).queryParameters['illust_id'];
            if (result != null) {
              try {
                results.add(int.parse(result));
              } catch (e) {}
            }
          }
        }
      });
      _streamController.add(1);
    } catch (e) {
      BotToast.showText(text: "error${e}");
    }
  }
}
