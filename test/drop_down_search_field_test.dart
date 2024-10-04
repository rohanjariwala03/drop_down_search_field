import 'package:drop_down_search_field/src/widgets/drop_down_search_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/drop_down_search_field_helper.dart';

/// Material DropdownSearchField widget tests where there are 6 dropDownSearchFields. To test overlays and other widgets.
void main() {
  group("Material DropDownSearchField widget tests", () {
    testWidgets("Initial UI Test", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialDropDownSearchFieldHelper
          .getMaterialDropDownSearchFieldPage());
      await tester.pumpAndSettle();

      expect(find.text("Material DropDownSearchField test"), findsOneWidget);
      expect(find.byType(DropDownSearchFormField<String>), findsNWidgets(6));
      expect(find.byType(CompositedTransformFollower), findsNothing);
    });

    testWidgets("No results found test", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialDropDownSearchFieldHelper
          .getMaterialDropDownSearchFieldPage());
      await tester.pumpAndSettle();

      final dropDownSearchField =
          find.byType(DropDownSearchFormField<String>).first;
      await tester.tap(dropDownSearchField);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(dropDownSearchField, "Chocolates");
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(CompositedTransformFollower), findsNWidgets(2));

      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text("No results found!"), findsOneWidget);
    });

    testWidgets("Search one item", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialDropDownSearchFieldHelper
          .getMaterialDropDownSearchFieldPage());
      await tester.pumpAndSettle();

      final dropDownSearchField =
          find.byType(DropDownSearchFormField<String>).first;
      await tester.tap(dropDownSearchField);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(dropDownSearchField, "Cheese");
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(CompositedTransformFollower), findsNWidgets(2));

      await tester.tap(find.text("Cheese").last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text("Cheese"), findsOneWidget);
    });

    testWidgets("Search two items", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialDropDownSearchFieldHelper
          .getMaterialDropDownSearchFieldPage());
      await tester.pumpAndSettle();

      final dropDownSearchField =
          find.byType(DropDownSearchFormField<String>).first;
      await tester.tap(dropDownSearchField);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(dropDownSearchField, "B");
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("Bread"), findsOneWidget);
      expect(find.text("Burger"), findsOneWidget);
    });

    testWidgets(
        "Search with first drop down search field and check the offset of the first suggestion box",
        (WidgetTester tester) async {
      // await tester.pumpWidget(MaterialDropDownSearchFieldHelper.getMaterialDropDownSearchFieldPage());
      // await tester.pumpAndSettle();

      // final dropDownSearchField = find.byType(DropDownSearchFormField<String>).first;
      // await tester.tap(dropDownSearchField);
      // await tester.pumpAndSettle(const Duration(seconds: 2));
      // await tester.enterText(dropDownSearchField, "Bread");
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      // final dropDownSearchFieldSuggestionBox = find.byType(CompositedTransformFollower).last;
      // final CompositedTransformFollower dropDownSearchFieldSuggestionBoxTester =
      //     tester.widget<CompositedTransformFollower>(dropDownSearchFieldSuggestionBox);
      // expect(dropDownSearchFieldSuggestionBoxTester.offset, const Offset(0.0, 61.0));
    });

    testWidgets(
        "Search with last drop down search fields and check the offset of the last suggestion box",
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialDropDownSearchFieldHelper
          .getMaterialDropDownSearchFieldPage());
      await tester.pumpAndSettle();

      final dropDownSearchField =
          find.byType(DropDownSearchFormField<String>).last;
      final scrollView = find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable));

      await tester.dragUntilVisible(
          dropDownSearchField, scrollView, const Offset(0, 1000));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(dropDownSearchField);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(dropDownSearchField, "Milk");
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final dropDownSearchFieldSuggestionBox =
          find.byType(CompositedTransformFollower).last;
      final CompositedTransformFollower dropDownSearchFieldSuggestionBoxTester =
          tester.widget<CompositedTransformFollower>(
              dropDownSearchFieldSuggestionBox);
      expect(dropDownSearchFieldSuggestionBoxTester.offset,
          const Offset(0.0, -5.0));
    });
  });
}
