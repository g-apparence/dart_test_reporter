# What is it

**Dart / Flutter project.** 
This project is a generator to generates documentations from tests. This use only annotations.
As flutter use functions to create tests you have to wrap your test inside classes. 
Note : this project is experimental.

# Install

Add this in your pubspec.yaml, in dev_dependencies
```
...
dev_dependencies:
  build_runner: ^1.8.0
  flutter_test:
    sdk: flutter
  bdd_test_generator:
    path: ../bdd_test_generator/
```

# create a documented test

Simply create your tests inside a class and add those annotations. 
The specification annotation define a list of scenario to tests for a feature. 

```dart
@Specification(
  title: "my feature title",
  asUser: "as an admin",
  want: "to connect")
class MyFeature {

  @Scenario(
    given: "given first scenario",
    when: "when 1",
    then: "then action 3")
  Future testMyFunction2(WidgetTester tester) async {
    var component = Container();
    var app = new MediaQuery(data: MediaQueryData(), child: MaterialApp(home: component));
    await tester.pumpWidget(app);
  }

  @Scenario(
    given: "a bad login and a non empty password",
    when: "I click on login button",
    then: "An error message is shown, password is reset")
  Future testMyFunction3(WidgetTester tester) async {
    var component = Container();
    var app = new MediaQuery(data: MediaQueryData(), child: MaterialApp(home: component));
    await tester.pumpWidget(app);
    // write my test here...
  }
}
```

# generate report and test files

Run the generator by running this command 
```
flutter packages pub run build_runner build 
```
