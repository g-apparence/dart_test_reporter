import 'dart:io';

import 'html_content_builder.dart';

class IndexFileHtmlBuilder {

  static const indexFileName = "index.html";

  String rootPath;
  Map<String, TestFileModel> files = Map();

  IndexFileHtmlBuilder(this.rootPath);

  addFile(String filename, String path, int nbTest) async {
    if(!files.containsKey(filename)) {
      files[filename] = TestFileModel(name: filename, path: path, nbTest: nbTest);
    }
    await _writeOnFile();
  }

  _writeOnFile() async {
    var myDir = new Directory(this.rootPath);
    var file = File(myDir.path + "/" + indexFileName);
    if(!file.existsSync()) {
      await file.create(recursive: true);
    }
    var baseContentBuilder = HtmlBaseContentBuilder("test report index", _createContent());
    await file.writeAsString(baseContentBuilder.generate(), mode: FileMode.writeOnly);
  }

  _createContent() {
    var content = StringBuffer();
    content.writeln('<div class="container mt-4">');
    content.writeln('        <h1 class="mb-4">Test report index</h1>');
    content.writeln('''
      <table class="table mt-4"><thead><tr>
      <th scope="col">#</th>
      <th scope="col">file name</th>
      <th scope="col">nb tests</th>
      </tr>
      </thead>
      <tbody>
    ''');
    files.forEach((key,model) {
      if(model.nbTest > 0) {
        content.writeln(_createLine(model));
      }
    });
    content.writeln('      </tbody></table>');
    content.writeln('    </div>');
    content.writeln("");
    return content.toString();
  }

  _createLine(TestFileModel model) {
    return '''
      <tr>
        <th scope="row">1</th>
        <td><a href="${model.path}">${model.name}</a></td>
        <td>${model.nbTest}</td>
      </tr>''';
  }
}

class TestFileModel {
  String name;
  String path;
  int nbTest;

  TestFileModel({this.name, this.path, this.nbTest});


}