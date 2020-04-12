import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/visitor.dart';

class HtmlBuilder implements Builder {

  final Generator generator;

  HtmlBuilder(this.generator);

  @override
  final buildExtensions = const {'.dart': ['.html']};

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final lib = await buildStep.inputLibrary;
    String contents = await _generate(lib, generator, buildStep);
    if(contents == null || contents.isEmpty) {
      return;
    }
    var inputId = buildStep.inputId;
    var copy = inputId.changeExtension('.html');
    var myDir = new Directory('./bddReporter');
    if(!(await myDir.exists())) {
      await myDir.create();
    }
    var file = File("${myDir.path}/${copy.path}");
    file.createSync(recursive: true);
    file.writeAsString(contents, flush: true);
  }
}

Future<String> _generate(LibraryElement library, Generator gen, BuildStep buildStep) async {
  final libraryReader = LibraryReader(library);
  var createdUnit = await gen.generate(libraryReader, buildStep);
  if (createdUnit == null) {
    return null;
  }
  createdUnit = createdUnit.trim();
  return createdUnit;
}