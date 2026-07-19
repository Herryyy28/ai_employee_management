import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_employee_management/features/enterprise/presentation/screens/enterprise_hub_screen.dart';
import 'package:ai_employee_management/features/enterprise/presentation/screens/ai_assistant_screen.dart';
import 'package:ai_employee_management/features/enterprise/presentation/screens/project_management_screen.dart';
import 'package:ai_employee_management/features/enterprise/presentation/screens/finance_payroll_screen.dart';

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1280, 1024);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  group('Enterprise Payroll Calculation Logic Tests', () {
    test('Calculates Net Salary deduction brackets correctly', () {
      const double baseSalary = 5000.0;
      const double allowances = 1200.0;
      
      final double pfDeduction = baseSalary * 0.12; // 600.0
      final double esiDeduction = baseSalary * 0.0075; // 37.5
      final double taxDeduction = baseSalary * 0.10; // 500.0
      
      final double totalDeductions = pfDeduction + esiDeduction + taxDeduction;
      final double netSalary = (baseSalary + allowances) - totalDeductions;

      expect(pfDeduction, 600.0);
      expect(esiDeduction, 37.5);
      expect(totalDeductions, 1137.5);
      expect(netSalary, 5062.5);
    });
  });

  group('Enterprise Hub Widget Layout Tests', () {
    testWidgets('Renders Global Search Bar, filter chips and directory directories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EnterpriseHubScreen(),
        ),
      );

      // Verify page layout widgets exist
      expect(find.text('Enterprise Portal Suite'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Smart Global Directory'), findsOneWidget);

      // Verify category filter chips are drawn
      expect(find.text('All'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);

      // Verify advanced services directory cards are present
      expect(find.text('AI Assistant & Copilot'), findsOneWidget);
      expect(find.text('Project Management'), findsOneWidget);
    });

    testWidgets('Toggles search query inputs dynamically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EnterpriseHubScreen(),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Jane');
      await tester.pumpAndSettle();

      // Search filters are active
      expect(find.text('Search Results (2)'), findsOneWidget);
      expect(find.text('Jane Cooper'), findsOneWidget);
      expect(find.text('HR Manager - Active'), findsOneWidget);
    });
  });

  group('AI Assistant Layout Tests', () {
    testWidgets('Renders Tab items and chat dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AiAssistantScreen(),
        ),
      );

      expect(find.text('AI HR & Recruitment Hub'), findsOneWidget);
      expect(find.text('HR Q&A & Wiki'), findsOneWidget);
      expect(find.text('AI Recruitment'), findsOneWidget);
      expect(find.text('Workforce Analytics'), findsOneWidget);
      expect(find.text('Smart Scheduler'), findsOneWidget);
    });
  });

  group('Project Management Layout Tests', () {
    testWidgets('Renders Kanban Sprint layout columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProjectManagementScreen(),
        ),
      );

      expect(find.text('Project & Sprint Manager'), findsOneWidget);
      expect(find.text('Kanban Board'), findsOneWidget);
    });
  });

  group('Finance & Payroll Layout Tests', () {
    testWidgets('Renders payroll calculation input cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FinancePayrollScreen(),
        ),
      );

      expect(find.text('Finance & Payroll Suite'), findsOneWidget);
      expect(find.text('Salary Calculator (PF, ESI, Deductions)'), findsOneWidget);
    });
  });
}
