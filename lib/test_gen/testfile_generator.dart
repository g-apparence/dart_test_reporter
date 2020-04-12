import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';


import 'package:meta/meta.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';

import '../annotations.dart';
import '../class_function_generator.dart';

Builder testGeneratorBuilder(BuilderOptions options) => LibraryBuilder(TestfileGenerator(), generatedExtension: '.bdd_test.dart');

class TestfileGenerator extends GeneratorForAnnotation<Specification> {

  var scenarioGenerator = ScenarioGenerator();

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    var content = await super.generate(library, buildStep);
    if(content == null || content.isEmpty) {
      return null;
    }
    var scenarGenerator = ScenarioGenerator();
    var scenario = await scenarGenerator.generate(library, buildStep);
    var buff = StringBuffer();
    buff.writeln("import 'package:flutter_test/flutter_test.dart';");
    buff.writeln("import '${library.element.source.shortName}';");
    buff.writeln("");
    buff.writeln("void main() {");
    buff.writeln(content);
    buff.writeln(scenario);
    buff.writeln("}");
    return buff.toString();
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if(element is ClassElement) {
      var buff = StringBuffer();
      buff.writeln("   var spec = ${element.name}();");
      buff.writeln("   ");
      return buff.toString();
    }
    return null;
  }

}


class ScenarioGenerator extends GeneratorForClassFunctionAnnotation<Scenario> {

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    var buff = StringBuffer();
    buff.writeln(await super.generate(library, buildStep));
    return buff.toString();
  }

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if(element is FunctionElement) {
      return _parseFunctions(element, annotation);
    } else if (element is MethodElement) {
      return _parseMethod(element, annotation);
    }
    return null;
  }

  String _parseFunctions(FunctionElement element, ConstantReader annotation) {
    return '''testWidgets('given: ${annotation.read("given").stringValue}, when: ${annotation.read("when").stringValue}', spec.${element.name});''';
  }

  String _parseMethod(MethodElement element, ConstantReader annotation) {
    return '''testWidgets('given: ${annotation.read("given").stringValue}, when: ${annotation.read("when").stringValue}', spec.${element.name});''';
  }

}




