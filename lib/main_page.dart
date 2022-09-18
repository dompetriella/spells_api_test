import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spells_test/providers.dart';
import 'models/spells.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> spellLookupList = [];

    Future getSpellsList() async {
      var dio = Dio();
      final response = await dio.get('https://api.open5e.com/spells/');
      int totalSpells = response.data['count'];

      // get first page
      response.data['results'].forEach((element) {
        spellLookupList.add(element['name']);
      });

      // get remaining pages
      var i = 2;
      while (spellLookupList.length < totalSpells) {
        int pageNumber = i;
        final response =
            await dio.get('https://api.open5e.com/spells/?page=$pageNumber');
        response.data['results'].forEach((element) {
          spellLookupList.add(element['name']);
        });
        i++;
      }
    }

    String convertToSlug(String name) {
      name = name.replaceAll(' ', '-');
      name = name.replaceAll("'", '');
      return name.toLowerCase();
    }

    Future<Spell> fetchSpell(String slug) async {
      var dio = Dio();
      String url = 'https://api.open5e.com/spells/$slug/';
      print(url);
      final response = await dio.get(url);

      return Spell(
          slug: response.data['slug'],
          name: response.data['name'],
          description: response.data['desc'],
          higherLevel: response.data['higher_level'],
          range: response.data['range'],
          material: response.data['material'],
          duration: response.data['duration'],
          level: response.data['level_int'],
          school: response.data['school']);
    }

    getSpellsList();

    return Scaffold(
      body: Container(
        child: ListView(children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return spellLookupList.where((String option) {
                option = option.toLowerCase();
                return option.contains(textEditingValue.text);
              });
            },
            onSelected: (String selection) async {
              debugPrint('You just selected $selection');
              ref.read(spellProvider.notifier).state =
                  await fetchSpell(convertToSlug(selection));
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: " + ref.watch(spellProvider).name),
              Text("Level: " +
                  (ref.watch(spellProvider).level > 0
                      ? ref.watch(spellProvider).level.toString()
                      : 'Cantrip')),
              Text("School: " + ref.watch(spellProvider).school),
              Text("Description: " + ref.watch(spellProvider).description),
              Text("Duration: " + ref.watch(spellProvider).duration),
              Text("Range: " + ref.watch(spellProvider).range),
            ],
          ),
        ]),
      ),
    );
  }
}
