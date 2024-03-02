import 'package:flutter/material.dart';
import 'package:skot/url.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final Function changeCurrentIndex;
  final Function changeAlbumRequested;
  final Function getAlbumsForUser;

  const ProfilePage(
      {super.key,
      required this.username,
      required this.changeCurrentIndex,
      required this.changeAlbumRequested,
      required this.getAlbumsForUser});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> jsonAlbums;

  @override
  void initState() {
    super.initState();
    jsonAlbums = widget.getAlbumsForUser(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: Image.network(
                '$url/audio/${widget.username.toLowerCase()}/logo.png',
                height: 120,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Icon(Icons.account_circle, size: 120);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.username,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Albums / Songs',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 600,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  children: List.generate(jsonAlbums.length, (index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        widget.changeAlbumRequested(
                            jsonAlbums.keys.toList()[index].toString());
                        widget.changeCurrentIndex(5);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    '$url/${jsonAlbums[jsonAlbums.keys.toList()[index]]['cover_path']}',
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        jsonAlbums.keys
                                            .toList()[index]
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        jsonAlbums[jsonAlbums.keys
                                                .toList()[index]]['artist']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 500),
          ],
        ),
      ),
    );
  }
}
