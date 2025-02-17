import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook_core/widgetbook_core.dart';

import 'addons/addons.dart';
import 'messaging/messaging.dart';
import 'routing/router.dart';
import 'state/state.dart';

/// Describes the configuration for your [Widget] library.
///
/// [Widgetbook] is the central element in organizing your widgets into
/// Folders and UseCases.
/// In addition, [Widgetbook] allows you to specify
/// - the [Theme]s used by your application,
/// - the [Device]s on which you'd like to preview the catalogued widgets
/// - the [Locale]s used by your application
///
/// [Widgetbook] defines the following constructors for different themes
/// - [Widgetbook]<[CustomTheme]> if you use a [CustomTheme] for your app
/// - [Widgetbook.cupertino] if you use [CupertinoThemeData] for your app
/// - [Widgetbook.material] if you use [ThemeData] for your app
///
/// Note: if you use for instance both [CupertinoThemeData] and [ThemeData] in
/// your app, use the [Widgetbook]<[CustomTheme]> constructor with [CustomTheme]
/// set to [dynamic] or [Object] and see [AppBuilderFunction] for how to
/// render custom themes.
class Widgetbook<CustomTheme> extends StatefulWidget {
  const Widgetbook({
    super.key,
    required this.appBuilder,
    required this.addons,
    this.directories = const <MultiChildNavigationNodeData>[],
  });

  final List<WidgetbookAddOn> addons;

  /// Children which host Packages, Folders, Categories, Components
  /// and Use cases.
  /// This can be used to organize the structure of the Widgetbook on a large
  /// scale.
  final List<MultiChildNavigationNodeData> directories;

  final AppBuilder appBuilder;

  /// A [Widgetbook] which uses cupertino theming via [CupertinoThemeData].
  static Widgetbook<CupertinoThemeData> cupertino({
    required List<MultiChildNavigationNodeData> directories,
    required List<WidgetbookAddOn> addons,
    AppBuilder? appBuilder,
    Key? key,
  }) {
    return Widgetbook<CupertinoThemeData>(
      key: key,
      directories: directories,
      addons: addons,
      appBuilder: appBuilder ?? cupertinoAppBuilder,
    );
  }

  /// A [Widgetbook] which uses material theming via [ThemeData].
  static Widgetbook<ThemeData> material({
    required List<MultiChildNavigationNodeData> directories,
    required List<WidgetbookAddOn> addons,
    AppBuilder? appBuilder,
    Key? key,
  }) {
    return Widgetbook<ThemeData>(
      key: key,
      directories: directories,
      addons: addons,
      appBuilder: appBuilder ?? materialAppBuilder,
    );
  }

  @override
  State<Widgetbook<CustomTheme>> createState() =>
      _WidgetbookState<CustomTheme>();
}

class _WidgetbookState<CustomTheme> extends State<Widgetbook<CustomTheme>> {
  late final GoRouter router;
  final NavigationBloc navigationBloc = NavigationBloc();

  @override
  void initState() {
    router = createRouter(
      addons: widget.addons,
      catalog: WidgetbookCatalog.fromDirectories(widget.directories),
      appBuilder: widget.appBuilder,
    );

    navigationBloc.add(
      LoadNavigationTree(
        directories: widget.directories,
      ),
    );

    // Sends a message with the json representation of Addon fields
    sendMessage(
      widget.addons.fold(
        {},
        (json, addon) {
          return json
            ..putIfAbsent(
              addon.slugName,
              () => addon.fields
                  .map(
                    (field) => field.toFullJson(),
                  )
                  .toList(),
            );
        },
      ),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Widgetbook<CustomTheme> oldWidget) {
    navigationBloc.add(LoadNavigationTree(directories: widget.directories));
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: navigationBloc,
      child: MaterialApp.router(
        routerConfig: router,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        darkTheme: Themes.dark,
        theme: Themes.light,
      ),
    );
  }
}
