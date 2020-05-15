# DynamicScreen - Content Creation On The Fly
Date of documentation: May 5th, 2020

## Table of Contents
- [Preamble](#preamble)  
- [Structure](#structure)
- [Configuration](#configuration)

<a name="preamble"></a>
## Preamble
The original goal to build this dynamic content creation engine was an ordinary feature request of having an onboarding flow after successful login. The premisse was to create a configuration file in JSON format which describes the requested content, and the engine takes it as a blueprint to build the UI at runtime.

First step is to have basic functionality by generating UI with texts in different styles, textfields, images, buttons and button-groups (like a set of radio buttons or checkboxes).

<a name="structure"></a>
## Structure
In general `DynamicScreen` consists of three parts:
* Configuration (JSON format)
* Model (JSON serializable Dart data classes)
* Widgets (with subgroups)
    * Screen Components
    * Page Components

You will find this structure reflected in the file system, too. Every part has its own directory containing belonging files. This is the current structure of `DynamicScreen` in file system:

<details>
<summary><i>File System Structure (Click to expand)</i></summary>

```shell
dynamic_screen
├── delegates
│   └── dynamic_screen_action_delegate.dart
├── dynamic_screen.dart
├── dynamic_screen_extensions.dart
├── dynamic_screen_model.dart
├── dynamic_screen_widgets.dart
├── extensions
│   └── list_apis.dart
├── model
│   ├── dynamic_screen.dart
│   ├── dynamic_screen.g.dart
│   ├── dynamic_screen_button.dart
│   ├── dynamic_screen_button.g.dart
│   ├── dynamic_screen_components.dart
│   ├── dynamic_screen_components.g.dart
│   ├── dynamic_screen_image.dart
│   ├── dynamic_screen_image.g.dart
│   ├── dynamic_screen_localizable.dart
│   ├── dynamic_screen_localizable.g.dart
│   ├── dynamic_screen_page.dart
│   ├── dynamic_screen_page.g.dart
│   ├── dynamic_screen_radio.dart
│   ├── dynamic_screen_radio.g.dart
│   ├── dynamic_screen_radio_list.dart
│   ├── dynamic_screen_radio_list.g.dart
│   ├── dynamic_screen_text.dart
│   ├── dynamic_screen_text.g.dart
│   ├── dynamic_screen_textfield.dart
│   └── dynamic_screen_textfield.g.dart
└── widgets
    ├── dynamic_screen.dart
    ├── page_components
    │   ├── page_base_component.dart
    │   ├── page_button_component.dart
    │   ├── page_image_component.dart
    │   ├── page_radio_list_component.dart
    │   ├── page_text_component.dart
    │   └── page_textfield_component.dart
    └── screen_components
        ├── dynamic_screen_navigation.dart
        ├── dynamic_screen_navigator.dart
        ├── dynamic_screen_page.dart
        ├── dynamic_screen_page_multi.dart
        └── dynamic_screen_page_single.dart
```
</details>

The files with the suffix `.g.dart` are dynamically generated Dart files, built by the Flutter [`build_runner`](https://pub.dev/packages/build_runner) plugin using [`json_annotation`](https://pub.dev/packages/json_annotation) and [`json_serializable`](https://pub.dev/packages/json_serializable). During development you can run this command in terminal (in the directory where the `pubspec.yaml` file of your project is) to let `build_runner` build these `.g.dart` files on the fly while you are editing your data classes. It's very convenient!

```
flutter packages pub run build_runner watch
```

**NOTE**: The file `dynamic_screen/dynamic_screen.dart` is a barrel file which exposes all the needed includes for creating `DynamicScreen` content in your project. So this file _should_ be the only one you have to include!

<a name="configuration"></a>
## Configuration
As mentioned above the entire configuration for `DynamicScreen` is based on one JSON file. A valid configuration could look like this example, which parts are described in detail below:

<details>
<summary><i>JSON Configuration Example (Click to expand)</i></summary>

```json
{
  "show_navigation": true,
  "pages": [
    {
      "name": "just an internal name",
      "padding": [32.0, 0.0, 32.0, 0.0],
      "components": [
        {
          "text": {
            "text_style": "title",
            "localizable": {
              "key": "onboardingPageProfileTitle",
              "value": "Profile"
            }
          }
        },
        {
          "text": {
            "text_style": "body1",
            "padding": [0.0, 24.0, 0.0, 24.0],
            "localizable": {
              "key": "onboardingPageProfileDescription",
              "value": "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. ..."
            }
          }
        },
        {
          "image": {
            "name": "onboarding_contact_list.png",
            "padding": [0.0, 24.0, 0.0, 0.0]
          }
        },
        {
          "button": {
            "importance": "high",
            "on_pressed": "fnOnPressed",
            "title": {
              "text_style": "button",
              "localizable": {
                "key": "buttonLabel",
                "value": "A Button"
              }
            }
          }
        },
        {
          "textfield": {
            "required": false,
            "label": {
              "text_style": "title",
              "localizable": {
                "key": "onboardingPageTextfieldLabel",
                "value": "Name"
              }
            },
            "placeholder": {
              "text_style": "subhead",
              "localizable": {
                "key": "onboardingPageTextfieldPlaceholder",
                "value": "Please enter your name"
              }
            }
          }
        }
      ]
    }
  ]
}
```
</details>