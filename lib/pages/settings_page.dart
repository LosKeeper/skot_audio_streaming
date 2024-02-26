import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  final int quality;
  final Function changeQuality;
  final Function changeCurrentIndex;

  const SettingsPage(
      {super.key,
      required this.quality,
      required this.changeQuality,
      required this.changeCurrentIndex});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? qualityValue;

  @override
  void initState() {
    super.initState();
    qualityValue = widget.quality == 0
        ? 'Normal'
        : widget.quality == 1
            ? 'High'
            : 'Ultimate';
  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(sections: [
      SettingsSection(
        title: const Text('Common Settings'),
        tiles: <SettingsTile>[
          SettingsTile.navigation(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            value: const Text('English'),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.music_note),
            title: const Text('Quality'),
            value: Text(qualityValue!),
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select Quality'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: const Text('Normal (16bit/44.1kHz MP3)'),
                          onTap: () {
                            widget.changeQuality(0);
                            setState(() {
                              qualityValue = 'Normal';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('High (24bit/48kHz FLAC)'),
                          onTap: () {
                            widget.changeQuality(1);
                            setState(() {
                              qualityValue = 'High';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Ultimate (24bit/96kHz WAV)'),
                          onTap: () {
                            widget.changeQuality(2);
                            setState(() {
                              qualityValue = 'Ultimate';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      SettingsSection(
        title: const Text('Version'),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('App Version'),
            value: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!.version);
                } else {
                  return const Text('Loading...');
                }
              },
            ),
            leading: const Icon(Icons.info),
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Credits'),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('Developed by'),
            value: const Text('Thomas Dumond aka LKP'),
            leading: const Icon(Icons.developer_mode),
          ),
          SettingsTile(
            title: const Text('SKOT Members'),
            value: const Text('LKP, Anybalsmith, Lesaul'),
            leading: const Icon(Icons.group),
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('SKOT Members'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('''
SKOT is a group of friends who are passionate about music and technology. Created in 2024 by LKP, Anybalsmith and Lesaul, the label is continously growing. The main goal of SKOT is to provide the best music experience to the world.''',
                            textAlign: TextAlign.justify),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Members:', textAlign: TextAlign.left),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('LKP'),
                          onTap: () {
                            widget.changeCurrentIndex(6, username: 'LKP');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Anybalsmith'),
                          onTap: () {
                            widget.changeCurrentIndex(6,
                                username: 'Anybalsmith');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Lesaul'),
                          onTap: () {
                            widget.changeCurrentIndex(6, username: 'Lesaul');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      )
    ]);
  }
}
