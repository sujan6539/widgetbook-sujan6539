import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook/src/routing/router.dart';
import 'package:widgetbook/src/state/state.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_core/widgetbook_core.dart';

void main() {
  final wbThemeLight = WidgetbookTheme(
    name: 'Light',
    data: ThemeData.light(),
  );
  final wbThemeDark = WidgetbookTheme(
    name: 'Dark',
    data: ThemeData.dark(),
  );

  final addons = [
    MaterialThemeAddon(
      themes: [
        wbThemeLight,
        wbThemeDark,
      ],
    ),
  ];

  final directories = [
    WidgetbookComponent(
      name: 'Component 1',
      useCases: [
        WidgetbookUseCase(
          name: 'Use-case 1.1',
          builder: (context) => const Text(
            'Text 1.1',
            key: ValueKey('Text 1.1'),
          ),
        ),
        WidgetbookUseCase(
          name: 'Use-case 1.2',
          builder: (context) => const Text(
            'Text 1.2',
            key: ValueKey('Text 1.2'),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'Component 2',
      useCases: [
        WidgetbookUseCase(
          name: 'Use-case 2.1',
          builder: (context) => const Text(
            'Text 2.1',
            key: ValueKey('Text 2.1'),
          ),
        ),
        WidgetbookUseCase(
          name: 'Use-case 2.2',
          builder: (context) => const Text(
            'Text 2.2',
            key: ValueKey('Text 2.2'),
          ),
        ),
      ],
    )
  ];

  final catalog = WidgetbookCatalog.fromDirectories(
    directories,
  );

  late NavigationBloc navigationBloc;

  setUp(
    () {
      navigationBloc = NavigationBloc();
    },
  );

  Future<void> pumpRouter({
    required WidgetTester tester,
    required GoRouter router,
  }) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => navigationBloc
          ..add(
            LoadNavigationTree(directories: directories),
          ),
        child: MaterialApp.router(
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
        ),
      ),
    );
  }

  group(
    'Router',
    () {
      group(
        'loads',
        () {
          testWidgets(
            'default route',
            (tester) async {
              final router = createRouter(
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final dropdownFinder = find.byWidgetPredicate(
                (widget) =>
                    widget is DropdownMenu<WidgetbookTheme<ThemeData>> &&
                    widget.initialSelection == wbThemeLight,
              );

              expect(dropdownFinder, findsOneWidget);
              expect(navigationBloc.state.selectedNode, isNull);
            },
          );

          testWidgets(
            'custom route',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?path=component-2%2Fuse-case-2.1',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final dropdownFinder = find.byWidgetPredicate(
                (widget) =>
                    widget is DropdownMenu<WidgetbookTheme<ThemeData>> &&
                    widget.initialSelection == wbThemeLight,
              );

              expect(dropdownFinder, findsOneWidget);
              expect(navigationBloc.state.selectedNode, isNotNull);
              expect(navigationBloc.state.selectedNode!.name, 'Use-case 2.1');
            },
          );

          testWidgets(
            'theme addon value',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?theme=Dark',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final dropdownFinder = find.byWidgetPredicate(
                (widget) =>
                    widget is DropdownMenu<WidgetbookTheme<ThemeData>> &&
                    widget.initialSelection == wbThemeDark,
              );

              expect(dropdownFinder, findsOneWidget);
              expect(navigationBloc.state.selectedNode, isNull);
            },
            skip: true,
          );

          testWidgets(
            'navigation panel only (deprecated)',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?disable-properties=true',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);

              expect(navigationFinder, findsOneWidget);
              expect(settingsFinder, findsNothing);
            },
          );

          testWidgets(
            'navigation panel only',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?panels={navigation}',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);

              expect(navigationFinder, findsOneWidget);
              expect(settingsFinder, findsNothing);
            },
          );

          testWidgets(
            'settings panel only (deprecated)',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?disable-navigation=true',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);

              expect(navigationFinder, findsNothing);
              expect(settingsFinder, findsOneWidget);
            },
          );

          testWidgets(
            'settings panel only',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?panels={knobs,addons}',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);

              expect(navigationFinder, findsNothing);
              expect(settingsFinder, findsOneWidget);
            },
          );

          testWidgets(
            'addons panel only',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?panels={addons}',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);
              final addonsFinder = find.text('Properties');
              final knobsFinder = find.text('Knobs');

              expect(navigationFinder, findsNothing);
              expect(settingsFinder, findsOneWidget);
              expect(addonsFinder, findsOneWidget);
              expect(knobsFinder, findsNothing);
            },
          );

          testWidgets(
            'knobs panel only',
            (tester) async {
              final router = createRouter(
                initialLocation: '/?panels={knobs}',
                addons: addons,
                catalog: catalog,
                appBuilder: materialAppBuilder,
              );

              await pumpRouter(
                tester: tester,
                router: router,
              );

              final navigationFinder = find.byType(NavigationPanelWrapper);
              final settingsFinder = find.byType(SettingsPanel);
              final addonsFinder = find.text('Properties');
              final knobsFinder = find.text('Knobs');

              expect(navigationFinder, findsNothing);
              expect(settingsFinder, findsOneWidget);
              expect(addonsFinder, findsNothing);
              expect(knobsFinder, findsOneWidget);
            },
          );
        },
      );
    },
  );
}
