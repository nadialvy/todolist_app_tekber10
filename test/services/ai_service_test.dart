import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todolist_app_tekber10/services/ai_service.dart';

void main() {
  group('AIService', () {
    group('generateTaskSteps - Mock AI Breakdown', () {
      // Note: These tests use the mock/fallback AI since no API key is loaded in tests
      
      test('should generate steps for design-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Design homepage wireframe');

        expect(result['steps'], isA<List>());
        expect(result['totalEstimatedMinutes'], isA<int>());
        
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        expect(steps.length, lessThanOrEqualTo(10));
        
        // Check step structure
        for (var step in steps) {
          expect(step['step'], isA<String>());
          expect(step['estimatedMinutes'], isA<int>());
        }
      });

      test('should generate steps for meeting-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Schedule team meeting');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        
        // Meeting tasks should have specific steps
        expect(steps.any((s) => s['step'].toString().toLowerCase().contains('agenda')), true);
      });

      test('should generate steps for study-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Study for math exam');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for report-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Write quarterly report');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for code-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Implement user authentication feature');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for review-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Review pull request');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate generic steps for unrecognized tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Random task xyz');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        expect(result['totalEstimatedMinutes'], isA<int>());
      });
    });

    group('totalEstimatedMinutes calculation', () {
      test('should calculate correct total from steps', () async {
        final result = await AIService.generateTaskSteps(title: 'Design mockup');

        final steps = result['steps'] as List;
        final expectedTotal = steps.fold<int>(
          0,
          (sum, step) => sum + (step['estimatedMinutes'] as int),
        );

        expect(result['totalEstimatedMinutes'], expectedTotal);
      });

      test('should return positive total estimated minutes', () async {
        final result = await AIService.generateTaskSteps(title: 'Any task');

        expect(result['totalEstimatedMinutes'], greaterThan(0));
      });
    });

    group('step structure validation', () {
      test('each step should have required fields', () async {
        final result = await AIService.generateTaskSteps(title: 'Test task');

        final steps = result['steps'] as List;
        for (var step in steps) {
          expect(step.containsKey('step'), true);
          expect(step.containsKey('estimatedMinutes'), true);
          expect(step['step'], isNotEmpty);
          expect(step['estimatedMinutes'], greaterThan(0));
        }
      });

      test('step descriptions should be meaningful strings', () async {
        final result = await AIService.generateTaskSteps(title: 'Code feature');

        final steps = result['steps'] as List;
        for (var step in steps) {
          final description = step['step'] as String;
          expect(description.length, greaterThan(5)); // Meaningful description
        }
      });
    });

    group('keyword detection', () {
      test('should detect "wireframe" as design task', () async {
        final result = await AIService.generateTaskSteps(title: 'Create wireframe');
        final steps = result['steps'] as List;
        
        // Design tasks typically have "inspiration" or "sketch" steps
        final hasDesignStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('inspiration') ||
          s['step'].toString().toLowerCase().contains('sketch') ||
          s['step'].toString().toLowerCase().contains('wireframe')
        );
        expect(hasDesignStep, true);
      });

      test('should detect "call" as meeting task', () async {
        final result = await AIService.generateTaskSteps(title: 'Client call tomorrow');
        final steps = result['steps'] as List;
        
        // Meeting tasks typically have "agenda" steps
        final hasMeetingStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('agenda') ||
          s['step'].toString().toLowerCase().contains('meeting')
        );
        expect(hasMeetingStep, true);
      });

      test('should detect "document" as report task', () async {
        final result = await AIService.generateTaskSteps(title: 'Document the API');
        final steps = result['steps'] as List;
        
        // Report tasks typically have "gather" or "outline" steps
        final hasReportStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('gather') ||
          s['step'].toString().toLowerCase().contains('outline') ||
          s['step'].toString().toLowerCase().contains('draft')
        );
        expect(hasReportStep, true);
      });

      test('should detect "build" as code task', () async {
        final result = await AIService.generateTaskSteps(title: 'Build login page');
        final steps = result['steps'] as List;
        
        // Code tasks typically have "requirements" or "implement" steps
        final hasCodeStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('requirements') ||
          s['step'].toString().toLowerCase().contains('implement') ||
          s['step'].toString().toLowerCase().contains('test')
        );
        expect(hasCodeStep, true);
      });

      test('should detect "feedback" as review task', () async {
        final result = await AIService.generateTaskSteps(title: 'Give feedback on design');
        final steps = result['steps'] as List;
        
        // Review tasks typically have "collect" or "observations" steps
        final hasReviewStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('collect') ||
          s['step'].toString().toLowerCase().contains('observations') ||
          s['step'].toString().toLowerCase().contains('review')
        );
        expect(hasReviewStep, true);
      });
    });

    group('case insensitivity', () {
      test('should handle uppercase keywords', () async {
        final result = await AIService.generateTaskSteps(title: 'DESIGN NEW FEATURE');

        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should handle mixed case keywords', () async {
        final result = await AIService.generateTaskSteps(title: 'DeVeLoP New Feature');

        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });
    });

    group('getApiKey', () {
      test('throws NotInitializedError when env not initialized', () {
        expect(() => AIService.getApiKey(), throwsA(anything));
      });
    });

    group('createMessages', () {
      test('returns system and user messages', () {
        final messages = AIService.createMessages('Test task', 'A description');

        expect(messages.length, 2);
        expect(messages[0]['role'], 'system');
        expect(messages[1]['role'], 'user');
        expect(messages[1]['content'], contains('Test task'));
        expect(messages[1]['content'], contains('A description'));
      });

      test('omits description in user message when null', () {
        final messages = AIService.createMessages('Just title', null);

        expect(messages[1]['content'], contains('Just title'));
        expect(messages[1]['content'], isNot(contains('description:')));
      });

      test('omits description in user message when empty string', () {
        final messages = AIService.createMessages('Just title', '');

        expect(messages[1]['content'], contains('Just title'));
        expect(messages[1]['content'], isNot(contains('description:')));
      });

      test('system message mentions ADHD focus', () {
        final messages = AIService.createMessages('x', null);
        expect(messages[0]['content']!.toLowerCase(), contains('adhd'));
      });
    });

    group('generateTaskSteps - HTTP path', () {
      tearDown(() {
        AIService.apiKeyOverride = null;
        AIService.httpClient = http.Client();
      });

      test('uses HTTP API when API key is set and returns parsed steps',
          () async {
        AIService.apiKeyOverride = 'fake-key';
        AIService.httpClient = MockClient((req) async {
          expect(req.headers['Authorization'], 'Bearer fake-key');
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'steps': [
                        {'step': 'AI step 1', 'estimatedMinutes': 10},
                        {'step': 'AI step 2', 'estimatedMinutes': 15},
                      ],
                      'totalEstimatedMinutes': 25,
                    }),
                  }
                }
              ],
            }),
            200,
          );
        });

        final result = await AIService.generateTaskSteps(
            title: 'Test', description: 'desc');
        expect(result['steps'], isA<List>());
        expect((result['steps'] as List).length, 2);
        expect(result['totalEstimatedMinutes'], 25);
      });

      test('falls back to simulation when API returns non-200', () async {
        AIService.apiKeyOverride = 'fake-key';
        AIService.httpClient = MockClient((req) async {
          return http.Response('Server error', 500);
        });

        final result = await AIService.generateTaskSteps(title: 'design');
        // Falls back — design keyword produces design steps.
        expect(result['steps'], isA<List>());
      });

      test('falls back when API returns 200 but content is missing',
          () async {
        AIService.apiKeyOverride = 'fake-key';
        AIService.httpClient = MockClient((req) async {
          return http.Response(jsonEncode({'choices': []}), 200);
        });

        final result = await AIService.generateTaskSteps(title: 'any task');
        expect(result['steps'], isA<List>());
      });

      test('falls back when HTTP throws', () async {
        AIService.apiKeyOverride = 'fake-key';
        AIService.httpClient = MockClient((req) async {
          throw Exception('Network error');
        });

        final result = await AIService.generateTaskSteps(title: 'meeting');
        expect(result['steps'], isA<List>());
      });

      test('calculates totalEstimatedMinutes when response omits it',
          () async {
        AIService.apiKeyOverride = 'fake-key';
        AIService.httpClient = MockClient((req) async {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'steps': [
                        {'step': 'A', 'estimatedMinutes': 7},
                        {'step': 'B', 'estimatedMinutes': 8},
                      ],
                      // no totalEstimatedMinutes
                    }),
                  }
                }
              ],
            }),
            200,
          );
        });

        final result = await AIService.generateTaskSteps(title: 'Test');
        expect(result['totalEstimatedMinutes'], 15);
      });
    });

    group('calculateTotalMinutes', () {
      test('sums estimatedMinutes from steps', () {
        final total = AIService.calculateTotalMinutes([
          {'step': 'a', 'estimatedMinutes': 10},
          {'step': 'b', 'estimatedMinutes': 5},
          {'step': 'c', 'estimatedMinutes': 15},
        ]);
        expect(total, 30);
      });

      test('returns 0 for empty list', () {
        expect(AIService.calculateTotalMinutes([]), 0);
      });

      test('skips entries with null estimatedMinutes', () {
        final total = AIService.calculateTotalMinutes([
          {'step': 'a', 'estimatedMinutes': 10},
          {'step': 'b', 'estimatedMinutes': null},
          {'step': 'c', 'estimatedMinutes': 5},
        ]);
        expect(total, 15);
      });

      test('skips non-map entries', () {
        final total = AIService.calculateTotalMinutes([
          'a string',
          {'step': 'b', 'estimatedMinutes': 7},
        ]);
        expect(total, 7);
      });

      test('handles num types (int and double)', () {
        final total = AIService.calculateTotalMinutes([
          {'step': 'a', 'estimatedMinutes': 5.5},
          {'step': 'b', 'estimatedMinutes': 4},
        ]);
        expect(total, 9);
      });
    });
  });
}

