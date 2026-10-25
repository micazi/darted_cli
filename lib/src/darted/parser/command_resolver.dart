import '../config/precedence_resolver.dart';
import '../helper/methods/find_command_closest_match.dart';
import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';
import '../validation/validation_result.dart';
import 'cli_token.dart';
import 'cli_tokenizer.dart';
import 'parsed_command_result.dart';

/// Resolves raw CLI arguments or tokens against a hierarchical [commandsTree].
class CommandResolver {
  final List<DartedCommand> commandsTree;
  final CliTokenizer tokenizer;
  final Map<String, dynamic>? configData;
  final Map<String, String>? environment;

  const CommandResolver(
    this.commandsTree, {
    this.tokenizer = const CliTokenizer(),
    this.configData,
    this.environment,
  });

  /// Resolves the given list of string [arguments].
  ParsedCommandResult? resolve(List<String> arguments) {
    final tokens = tokenizer.tokenize(arguments);
    return resolveTokens(tokens);
  }

  /// Resolves tokenized [tokens] against [commandsTree].
  ParsedCommandResult? resolveTokens(List<CliToken> tokens) {
    if (tokens.isEmpty) {
      return null;
    }

    // Check if the very first token is a root-level version or help request
    if (tokens.first is LongOptionToken) {
      final opt = tokens.first as LongOptionToken;
      if (opt.name == 'version' || opt.name == 'v') {
        // Return synthetic result or handle at entry level
      }
    }

    // Step 1: Traverse the command tree to find the target command
    final commandPath = <DartedCommand>[];
    var currentLevel = commandsTree;
    var tokenIndex = 0;

    while (tokenIndex < tokens.length) {
      final token = tokens[tokenIndex];

      if (token is WordToken) {
        final match = currentLevel
            .where((c) => c.name.toLowerCase() == token.value.toLowerCase())
            .firstOrNull;

        if (match != null) {
          commandPath.add(match);
          currentLevel = match.subCommands ?? [];
          tokenIndex++;
          continue;
        } else {
          // If no command matched yet, the first word was an unrecognized root command
          if (commandPath.isEmpty) {
            final available = currentLevel.map((c) => c.name).toList();
            final suggestion = getClosestMatch(token.value, available);
            throw UnknownCommandException(token.value,
                closestMatch: suggestion);
          }
          // Otherwise, this word is a positional argument for the matched command
          break;
        }
      } else {
        // Encountered an option/flag or '--', stop command traversal
        break;
      }
    }

    if (commandPath.isEmpty) {
      // Input only contains options/flags without any command name
      return null;
    }

    final targetCommand = commandPath.last;

    // Step 2: Index declared arguments and flags for the resolved command
    final availableArgs =
        (targetCommand.arguments ?? []).whereType<DartedArgument>().toList();
    final availableFlags = [
      DartedFlag.help,
      DartedFlag.version,
      ...?targetCommand.flags,
    ];

    final argsByName = <String, DartedArgument>{};
    final argsByAbbr = <String, DartedArgument>{};
    for (final arg in availableArgs) {
      argsByName[arg.name.toLowerCase()] = arg;
      if (arg.abbreviation.isNotEmpty) {
        argsByAbbr[arg.abbreviation.toLowerCase()] = arg;
      }
    }

    final flagsByName = <String, DartedFlag>{};
    final flagsByAbbr = <String, DartedFlag>{};
    for (final flag in availableFlags) {
      flagsByName[flag.name.toLowerCase()] = flag;
      if (flag.abbreviation.isNotEmpty) {
        flagsByAbbr[flag.abbreviation.toLowerCase()] = flag;
      }
    }

    // Step 3: Parse remaining tokens (options, flags, positionals)
    final parsedArgs = <String, dynamic>{};
    final parsedFlags = <String, bool>{};
    final positionals = <String>[];
    final rest = <String>[];

    var inRestMode = false;

    while (tokenIndex < tokens.length) {
      final token = tokens[tokenIndex];

      if (inRestMode) {
        if (token is WordToken) {
          rest.add(token.value);
        } else {
          rest.add(token.raw);
        }
        tokenIndex++;
        continue;
      }

      if (token is EndOfOptionsToken) {
        inRestMode = true;
        tokenIndex++;
        continue;
      }

      if (token is WordToken) {
        positionals.add(token.value);
        tokenIndex++;
        continue;
      }

      if (token is LongOptionToken) {
        final rawName = token.name;
        final lowerName = rawName.toLowerCase();

        // 1. Check for flag negation: --no-<flag>
        if (lowerName.startsWith('no-')) {
          final stripped = lowerName.substring(3);
          final flag = flagsByName[stripped];
          if (flag != null) {
            if (!flag.canBeNegated) {
              throw FlagCannotBeNegatedException(
                flag.name,
                command: targetCommand.name,
              );
            }
            parsedFlags[flag.name] = false;
            tokenIndex++;
            continue;
          }
        }

        // 2. Check for boolean flag match
        final flag = flagsByName[lowerName];
        if (flag != null) {
          parsedFlags[flag.name] = true;
          tokenIndex++;
          continue;
        }

        // 3. Check for argument match
        final arg = argsByName[lowerName];
        if (arg != null) {
          if (token.hasInlineValue) {
            parsedArgs[arg.name] = token.inlineValue!;
            tokenIndex++;
          } else {
            // Value is in the next token
            if (tokenIndex + 1 >= tokens.length) {
              throw MissingArgumentValueException(
                '--$rawName',
                command: targetCommand.name,
              );
            }

            final nextToken = tokens[tokenIndex + 1];
            if (nextToken is LongOptionToken ||
                nextToken is EndOfOptionsToken) {
              throw MissingArgumentValueException(
                '--$rawName',
                command: targetCommand.name,
              );
            }

            parsedArgs[arg.name] = nextToken.raw;
            tokenIndex += 2;
          }
          continue;
        }

        // 4. Unknown long option
        final searchCandidates = [
          ...argsByName.keys.map((k) => '--$k'),
          ...flagsByName.keys.map((k) => '--$k'),
        ];
        final suggestion = getClosestMatch('--$lowerName', searchCandidates);
        throw UnknownOptionException(
          '--$rawName',
          command: targetCommand.name,
          closestMatch: suggestion,
        );
      }

      if (token is ShortOptionToken) {
        final content = token.rawContent;

        // 1. Attached value: -n=value
        if (content.contains('=')) {
          final eqIndex = content.indexOf('=');
          final optChar = content.substring(0, eqIndex).toLowerCase();
          final value = content.substring(eqIndex + 1);
          final arg = argsByAbbr[optChar];
          if (arg != null) {
            parsedArgs[arg.name] = value;
            tokenIndex++;
            continue;
          }
        }

        // 2. Attached value without =: -nvalue (e.g. -p8080)
        if (content.length > 1) {
          final firstChar = content[0].toLowerCase();
          final arg = argsByAbbr[firstChar];
          if (arg != null) {
            parsedArgs[arg.name] = content.substring(1);
            tokenIndex++;
            continue;
          }

          // 3. Combined short flags: -rf
          var allMatchFlags = true;
          final matchedFlags = <DartedFlag>[];
          for (var j = 0; j < content.length; j++) {
            final char = content[j].toLowerCase();
            final fl = flagsByAbbr[char];
            if (fl != null) {
              matchedFlags.add(fl);
            } else {
              allMatchFlags = false;
              break;
            }
          }

          if (allMatchFlags && matchedFlags.isNotEmpty) {
            for (final fl in matchedFlags) {
              parsedFlags[fl.name] = true;
            }
            tokenIndex++;
            continue;
          }
        }

        // 4. Single short flag or option: -f or -n <val>
        final singleChar = content.toLowerCase();
        final flag = flagsByAbbr[singleChar];
        if (flag != null) {
          parsedFlags[flag.name] = true;
          tokenIndex++;
          continue;
        }

        final arg = argsByAbbr[singleChar];
        if (arg != null) {
          if (tokenIndex + 1 >= tokens.length) {
            throw MissingArgumentValueException(
              '-$content',
              command: targetCommand.name,
            );
          }
          final nextToken = tokens[tokenIndex + 1];
          if (nextToken is LongOptionToken || nextToken is EndOfOptionsToken) {
            throw MissingArgumentValueException(
              '-$content',
              command: targetCommand.name,
            );
          }
          parsedArgs[arg.name] = nextToken.raw;
          tokenIndex += 2;
          continue;
        }

        // 5. Unknown short option
        throw UnknownOptionException(
          '-$content',
          command: targetCommand.name,
        );
      }

      tokenIndex++;
    }

    final isHelp = parsedFlags[DartedFlag.help.name] == true ||
        parsedFlags[DartedFlag.help.abbreviation] == true;
    final isVersion = parsedFlags[DartedFlag.version.name] == true ||
        parsedFlags[DartedFlag.version.abbreviation] == true;

    // Step 4: Apply 4-tier Precedence (CLI > Env > Config > Defaults) and validate
    final precedence = PrecedenceResolver(
      configData: configData,
      environment: environment,
    );

    final resolved = precedence.resolve(
      command: targetCommand,
      commandPath: commandPath.map((c) => c.name).toList(),
      explicitCliArguments: parsedArgs,
      explicitCliFlags: parsedFlags,
      positionals: positionals,
      isHelpOrVersion: isHelp || isVersion,
    );

    return ParsedCommandResult(
      command: targetCommand,
      commandPath: commandPath,
      arguments: resolved.arguments,
      flags: resolved.flags,
      positionalArguments: positionals,
      rest: rest,
    );
  }
}
