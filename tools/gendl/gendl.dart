import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

const appName = "GENDL - Generate Dynamic Localizations";
const appVersion = "0.1.0";

// Script Arguments
const argHelp = "help";
const argVerbose = "verbose";
const argJson = "json";
const argDart = "dart";
const argDartDefault = "l_dynamic.dart";

// Parser Configuration
ArgResults argResults;
final parser = ArgParser()
  ..addFlag(argHelp, abbr: 'h', negatable: false, help: "Shows this help")
  ..addFlag(argVerbose, abbr: 'v', defaultsTo: false, negatable: false, help: "Turns on verbose mode")
  ..addOption(argJson, abbr: "j", valueHelp: 'JSON file path', help: "Give the source JSON file which should be parsed for available dynamic localizations.")
  ..addOption(argDart, abbr: "d", valueHelp: 'Dart file path', defaultsTo: argDartDefault)
;

Future<void> main(List<String> arguments) async {
  try {
    argResults = parser.parse(arguments);

    if (argResults.arguments.length == 0 || argResults[argHelp]) {
      showVersionAndUsage();
    } else {
      await generateLocalizationsAsync(argResults);
    }
    exit(0);

  } catch (error) {
    showError(error.toString());
  }
}

Future<void> generateLocalizationsAsync(ArgResults argResults) async {
  final jsonPath = argResults[argJson];
  final jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    showError("The requested file doesn't exists! Aborting...\n\tJSON File: $jsonPath");
  }

  final dartPath = argResults[argDart];
  final dartFile = File(dartPath);

  if (!dartFile.existsSync()) {
    dartFile.createSync(recursive: true);
  }

  final extensionOpen = '''
import 'package:ox_coi/src/l10n/l.dart';

/*
 ************************************************************************* 
 AUTOMATICALLY GENERATED FILE. DO NOT EDIT, ALL YOUR CHANGES WILL BE LOST!
 *************************************************************************
*/ 

class DynamicLocalizations extends L {
''';
  final extensionClose = "}\n";
  final jsonString = await jsonFile.readAsString();
  final Map<String, dynamic> json = jsonDecode(jsonString);

  Map<String, String> localizables = {};
  localizables.addEntries(getLocalizablesFor(component: json).entries);

  dartFile.writeAsStringSync(extensionOpen);
  localizables.keys.forEach((key) {
    final staticFinal = 'static final $key = L.translationKey("${localizables[key]}");';
    dartFile.writeAsStringSync("\t$staticFinal\n", mode: FileMode.append);
    log("[Generated] $staticFinal");
  });
  dartFile.writeAsStringSync(extensionClose, mode: FileMode.append);
}

Map<String, String> getLocalizablesFor({Map<String, dynamic> component}) {
  Map<String, String> result = {};
  component.keys.forEach((key) {
    final item = component[key];
    if (item is Map<String, dynamic>) {
      if (key == 'localizable') {
        result[item['key']] = item['value'];
      } else {
        result.addEntries(getLocalizablesFor(component: item).entries);
      }
    } else if (item is List<dynamic>) {
      item.forEach((listItem) {
        if (listItem is Map<String, dynamic>) {
          result.addEntries(getLocalizablesFor(component: listItem).entries);
        }
      });
    }
  });
  return result;
}

void log(String logMsg) {
  if (!argResults[argVerbose]) return;
  print("$logMsg");
}

void showError(String errMsg) {
  print("[ERROR] $errMsg\n");
  showUsage();
  exit(2);
}

void showVersion() {
  print("$appName, v$appVersion\n");
}

void showUsage() {
  print(parser.usage);
}

void showVersionAndUsage() {
  showVersion();
  showUsage();
}
