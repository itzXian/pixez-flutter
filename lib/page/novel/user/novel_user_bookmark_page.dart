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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelUserBookmarkPage extends HookWidget {
  final int id;
  NovelUserBookmarkPage(this.id);
  @override
  Widget build(BuildContext context) {
    final restrict = useState<String>('public');
    final futureGet = useState<FutureGet>(
        () => apiClient.getUserBookmarkNovel(id, restrict.value));
    return Column(
      children: [
        IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              futureGet.value = () =>
                                  apiClient.getUserBookmarkNovel(id, 'public');
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).private),
                            onTap: () {
                              futureGet.value = () =>
                                  apiClient.getUserBookmarkNovel(id, 'private');
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  });
            }),
        NovelLightingList(
          futureGet: futureGet.value,
        ),
      ],
    );
  }
}
