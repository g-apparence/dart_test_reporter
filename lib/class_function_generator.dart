import 'dart:async';

import 'package:source_gen/source_gen.dart';
import 'package:meta/meta.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';

abstract class GeneratorForClassFunctionAnnotation<T> extends Generator {
  const GeneratorForClassFunctionAnnotation();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  DartObject getAnnotation(Element element) {
    var annotations = typeChecker.annotationsOf(element);
    if (annotations.isEmpty) {
      return null;
    }
    if (annotations.length > 1) {
      throw Exception(
        "You tried to add multiple @$T() annotations to the "
          "same element but that's not possible.");
    }
    return annotations.single;
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};
    for (var el in library.allElements) {
      if (el is ClassElement && !el.isEnum) {
        for(final method in el.methods) {
          var annotatedElement = getAnnotation(method);
          if(annotatedElement == null) {
            continue;
          }
          try {
            final generatedValue = await generateForAnnotatedElement(method, ConstantReader(annotatedElement), buildStep);
            if(generatedValue != null && generatedValue.isNotEmpty) {
              values.add(generatedValue);
            }
          } catch (e) {
            values.add("   (error $e)");
          }
        }
      }
    }
    return values.join('\n\n');
  }

  /// Implement to return source code to generate for [element].
  ///
  /// This method is invoked based on finding elements annotated with an
  /// instance of [T]. The [annotation] is provided as a [ConstantReader].
  ///
  /// Supported return values include a single [String] or multiple [String]
  /// instances within an [Iterable] or [Stream]. It is also valid to return a
  /// [Future] of [String], [Iterable], or [Stream].
  ///
  /// Implementations should return `null` when no content is generated. Empty
  /// or whitespace-only [String] instances are also ignored.
  FutureOr<String> generateForAnnotatedElement(
    Element element, ConstantReader annotation, BuildStep buildStep);
}