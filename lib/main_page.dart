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
      print(name);
      name = name.replaceAll(RegExp(r'[^\w\s]+'), '');
      name = name.replaceAll(' ', '-');
      print(name);
      return name.toLowerCase();
    }

    Future<Spell> fetchSpell(String slug) async {
      var dio = Dio();
      String url = 'https://api.open5e.com/spells/$slug/';
      print(url);
      final response = await dio.get(url);

      return Spell.fromJson(response.data);
    }

    String getTrailing(int num) {
      String returnString = '';
      switch (num) {
        case 1:
          returnString = 'st';
          break;
        case 1:
          returnString = 'st';
          break;
        case 2:
          returnString = 'nd';
          break;
        case 3:
          returnString = 'rd';
          break;
        default:
          returnString = 'th';
      }

      return returnString;
    }

    String capitalize(String inputString) {
      return "${inputString[0].toUpperCase()}${inputString.substring(1).toLowerCase()}";
    }

    getSpellsList();

    var scSize = MediaQuery.of(context).size;
    TextStyle heading = TextStyle(fontWeight: FontWeight.w800, fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Magic Answer Lookup"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("parchment_bg.jpg"),
                fit: BoxFit.cover,
                opacity: .72)),
        child: Center(
          child: Container(
            width: scSize.width * .85,
            height: scSize.height * .85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView(children: [
              Autocomplete<String>(
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: SizedBox(
                      width: scSize.width * .85,
                      child: ListView(
                        children: options
                            .map((e) => ListTile(
                                  onTap: () => onSelected(e),
                                  title: Text(e),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
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
                    decoration: InputDecoration.collapsed(
                        hintText: 'Start typing a spell...'),
                    autofocus: true,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 35),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 15, 8.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ref.watch(spellProvider).name != '')
                      Center(
                        child: Text(
                          "${ref.watch(spellProvider).level > 0 ? ((ref.watch(spellProvider).level.toString() + getTrailing(ref.watch(spellProvider).level) + ' Level')) : 'Cantrip'} ${capitalize(ref.watch(spellProvider).school)}",
                          style: TextStyle(
                              fontWeight: FontWeight.w200, fontSize: 20),
                        ),
                      ),
                    Center(
                        child: Text(
                      ref.watch(spellProvider).classes,
                      style:
                          TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
                    )),
                    if (ref.watch(spellProvider).name != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Duration",
                          style: heading,
                        ),
                      ),
                    Text(ref.watch(spellProvider).duration),
                    if (ref.watch(spellProvider).name != '')
                      Text("Range", style: heading),
                    Text(ref.watch(spellProvider).range),
                    if (ref.watch(spellProvider).name != '')
                      Text(
                        "Casting Time",
                        style: heading,
                      ),
                    Text(ref.watch(spellProvider).castingTime),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        ref.watch(spellProvider).description,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
