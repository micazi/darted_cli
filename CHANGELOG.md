## 0.2.1
**FIX**: Fixed issues in subcommands main argument parsing.

## 0.2.0
**FEAT**: Added an option to set an argument as 'main' which would allow the user to pass it in as a required positioned argument without it's name. e.g. `your_package command neededArg --otherOptionalArgName otherArgValue`.
**Breaking Change**: Added functionality to find the closest match of misspelled commands and arguments, and are now passed in the custom Error Callbacks.
**FEAT**: updated 'defaultHelperMessage' implementation.
**FEAT**: updated Darted models with `.copyWith()` implementation.
**DOCS**: updated CHANGELOG file to be newest-first.

---

## 0.1.27
**FIX**: updated executeCommand function to run in shell with in the Windows platform to allow for executables to run.
**FEAT**: updated executeCommand function to pass-through stdout text.

## 0.1.26
**FIX**: updated misspelled 'description' wording.
**FIX**: updated getUserInput function to work with consecutive requests as it threw 'Stream has already been listened to' before.

## 0.1.25

**FIX**: Recursive map validation wasn't behaving as expected with nested `required` fields.
**FEAT**: Updated the `matchesPattern` parameter of the schema validation to apply to List types.

## 0.1.24
**FEAT**: Added `DartToYaml` Converter to revert back the extraction process.

## 0.1.23

**FIX**: Copy methods for both files and directories not working.
**DOC**: Updated License file for 2025.

## 0.1.22

**FEAT**: Added custom validation exceptions for the YAML module.
**FEAT**: Added Recursive map validation for structure-like YAML components.
**DOC**: Updated the format of the `CHANGELOG` file.
**DOC**: Updated the example file.

## 0.1.21

**FEAT**: New updates to the YAML validation module!

## 0.1.20

**FEAT**: Added option to enable recursion in the 'listAll' functions of both files and directories.

## 0.1.19

**FEAT**: Added YAML Data Extraction functionality into `Map<String,dynamic>`.

## 0.1.18

**FEAT**: Added YAML Validation functionality using a schema, See the example main.dart for usage.

## 0.1.17

**FEAT**: Added description to `dartedFlag` and `dartedArgument` models.

## 0.1.16

**DEPS**: Updated dependencies & Added `allowed` and `excluded` parameters in the ListAll functions.

## 0.1.15

**FIX**: Fix in the searchFiles function for incorrect line content indentations.

## 0.1.14

**FIX**: Fix in the searchFiles function for incorrect position matches.

## 0.1.13

**FEAT**: Updated the searchFiles method to include the matches' starting position to make it easier to manipulate + Added 'allowed' parameter for it to search only certain files based on a RegExp pattern.

## 0.1.12

**CHORE**: Static Analysis Updates.

## 0.1.11

**FEAT**: Added 'chooseOption' method that Prompts the user to choose an option (Single/Multi).

## 0.1.10

**CHORE**: Some minor fixes.

## 0.1.9

**FEAT**: Added 'executeCommand' to the console helper.

## 0.1.8

**FEAT**: Added new 'Copy' methods.

## 0.1.7

**FEAT**: Updated the implementation to create Files.

## 0.1.6

**FEAT**: Added two methods for the IO Helper to list files/directories in a root path.

## 0.1.5

**FIX**: Fixed 'help/version flags that are applied by default not being parsed'.

## 0.1.4

**FIX**: asset-related fixes.

## 0.1.3

**DOC**: Documentation Fixes.

## 0.1.2

**FIX**: Fixed some assets-related issues.

## 0.1.1

**FEAT**: Added custom ASCII Fonts for the Art.

## 0.1.0

**INIT**: Initial Release.