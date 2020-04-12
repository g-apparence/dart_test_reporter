import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/visitor.dart';

import '../annotations.dart';
import '../class_function_generator.dart';
import 'html_builder.dart';
import 'html_content_builder.dart';
import 'index_builder.dart';

// root folder of all html report files inside our project
const folderPath = './bddReporter';

Builder bddReporter(BuilderOptions options) {
  _clearFolder();
  var indexFileBuilder = IndexFileHtmlBuilder(folderPath);
  return HtmlBuilder(BddReporterGenerator(indexFileBuilder));
}

_clearFolder() {
  var myDir = new Directory(folderPath);
  if(myDir.existsSync()) {
    myDir.deleteSync(recursive: true);
  }
}


class BddReporterGenerator extends GeneratorForAnnotation<Specification> {

  IndexFileHtmlBuilder indexFileBuilder;

  BddReporterGenerator(this.indexFileBuilder);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    String header = await super.generate(library, buildStep);
    var scenarioGenerator = ScenarioHtmlGenerator();
    String scenario = await scenarioGenerator.generate(library, buildStep);
    if(scenarioGenerator.scenarios.length == 0) {
      return null;
    }
    var inputId = buildStep.inputId;
    var copy = inputId.changeExtension('.html');
    await indexFileBuilder.addFile(
      library.element.source.shortName,
      copy.path,
      scenarioGenerator.scenarios.length);
    return HtmlContentBuilder(library.element.source.shortName, header, scenario).generate();
  }

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    Specification specification = Specification(
      title:  annotation.peek("title")?.stringValue,
      asUser: annotation.peek("asUser")?.stringValue,
      want: annotation.peek("want")?.stringValue,
      that: annotation.peek("that")?.stringValue,
    );
    var specifHtmlBuilder = HtmlSpecificationBuilder(specification);
    return specifHtmlBuilder.generate();
  }

}


class ScenarioHtmlGenerator extends GeneratorForClassFunctionAnnotation<Scenario> {

  List<Scenario> scenarios = new List();

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
    return _parseAnnotation(annotation);
  }

  String _parseMethod(MethodElement element, ConstantReader annotation) {
    return _parseAnnotation(annotation);
  }

  _parseAnnotation(ConstantReader annotation) {
    Scenario scenario = Scenario(
      given: annotation.read("given").stringValue,
      when: annotation.read("when").stringValue,
      then: annotation.read("then").stringValue
    );
    this.scenarios.add(scenario);
    var htmlContentBuilder = HtmlLineBuilder(scenario);
    return htmlContentBuilder.generate();
  }

}


class HtmlSpecificationBuilder {
  Specification specification;

  HtmlSpecificationBuilder(this.specification);

  String generate() {
    return '''
      <div class="card mt-2">
        <div class="card-body">
          <h5 class="card-title">${specification?.title}</h5>
          <p class="card-text">
            As : ${specification?.asUser}<br/>
            want : ${specification?.want}<br/>
            that : ${specification?.that ?? ""}
          </p>
        </div>
      </div>
    ''';
  }
}


class HtmlLineBuilder {

  Scenario scenario;

  HtmlLineBuilder(this.scenario);

  String generate() {
    return '''
      <tr>
        <th scope="row">1</th>
        <td>${scenario.given}</td>
        <td>${scenario.when}</td>
        <td>${scenario.then}</td>
      </tr>
    ''';
  }
}



