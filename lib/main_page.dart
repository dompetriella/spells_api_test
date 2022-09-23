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

      return Spell.fromJson(response.data);
    }

    getSpellsList();

    var scSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Container(
            width: scSize.width * .85,
            height: scSize.height * .75,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: ListView(children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return spellLookupList.where((String option) {
                    option = option.toLowerCase();
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) async {
                  debugPrint('You just selected $selection');
                  ref.read(spellProvider.notifier).state =
                      await fetchSpell(convertToSlug(selection));
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    autofocus: true,
                    autofillHints: ['Start typing a spell...'],
                    textAlign: TextAlign.center,
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ref.watch(spellProvider).name != '') Text("Name"),
                  Text(ref.watch(spellProvider).name),
                  if (ref.watch(spellProvider).name != '') Text("Level"),
                  if (ref.watch(spellProvider).name != '')
                    Text(ref.watch(spellProvider).level > 0
                        ? ref.watch(spellProvider).level.toString()
                        : 'Cantrip'),
                  if (ref.watch(spellProvider).name != '') Text("Duration"),
                  Text(ref.watch(spellProvider).duration),
                  if (ref.watch(spellProvider).name != '') Text("Range"),
                  Text(ref.watch(spellProvider).range),
                  if (ref.watch(spellProvider).classes.isNotEmpty)
                    Text("Classes"),
                  if (ref.watch(spellProvider).classes.isNotEmpty)
                    Text(ref.watch(spellProvider).classes.toString()),
                  if (ref.watch(spellProvider).name != '') Text("School"),
                  Text(ref.watch(spellProvider).school),
                  if (ref.watch(spellProvider).name != '') Text("Description"),
                  Text(ref.watch(spellProvider).description),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
