import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_error_formatter.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/presentation/widgets/app_error_state.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/attempt/attempt_providers.dart';
import 'package:quiz_battle/features/attempt/domain/quiz_submit_validator.dart';
import 'package:quiz_battle/features/attempt/presentation/models/quiz_result_args.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';
import 'package:quiz_battle/features/quiz/data/models/quiz_question.dart';
import 'package:quiz_battle/features/quiz/quiz_providers.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Plays an [ActiveQuiz] from the active list: one MCQ at a time, timer, local answers, single submit.
class QuizPlayScreen extends ConsumerStatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.quizId,
    this.quizTitle,
    this.initialQuiz,
  });

  final String quizId;
  final String? quizTitle;
  final ActiveQuiz? initialQuiz;

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  ActiveQuiz? _quiz;
  bool _loadingQuiz = false;
  Object? _loadFailure;
  bool _pendingResultNavigation = false;

  int _questionIndex = 0;
  final Map<String, int?> _answers = {};

  Timer? _countdown;
  int _secondsLeft = 0;

  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final incoming = widget.initialQuiz;
    if (incoming != null &&
        incoming.id == widget.quizId &&
        incoming.questions.isNotEmpty) {
      if (incoming.hasCompletedAttempt) {
        _pendingResultNavigation = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navigateToResult(incoming);
        });
        return;
      }
      _quiz = incoming;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restartQuestionTimer();
      });
    } else {
      unawaited(_resolveQuizFromApi());
    }
  }

  void _navigateToResult(ActiveQuiz quiz) {
    final displayTitle = widget.quizTitle?.trim().isNotEmpty == true
        ? widget.quizTitle!.trim()
        : quiz.title;
    final score = quiz.myAttempt?.score;
    context.goNamed(
      RouteNames.quizResult,
      pathParameters: {'quizId': quiz.id},
      extra: QuizResultArgs(
        quizId: quiz.id,
        quizTitle: displayTitle,
        totalQuestions: quiz.questions.length,
        score: score,
      ),
    );
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _resolveQuizFromApi() async {
    setState(() {
      _loadingQuiz = true;
      _loadFailure = null;
    });
    try {
      final list = await ref.read(activeQuizzesProvider.future);
      ActiveQuiz? match;
      for (final q in list) {
        if (q.id == widget.quizId) {
          match = q;
          break;
        }
      }
      if (!mounted) return;
      if (match == null || match.questions.isEmpty) {
        setState(() {
          _loadingQuiz = false;
          _loadFailure = 'This quiz is not available or has no questions.';
        });
        return;
      }
      if (match.hasCompletedAttempt) {
        if (!mounted) return;
        setState(() => _loadingQuiz = false);
        _navigateToResult(match);
        return;
      }
      setState(() {
        _quiz = match;
        _loadingQuiz = false;
      });
      _restartQuestionTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQuiz = false;
        _loadFailure = e;
      });
    }
  }

  QuizQuestion? get _currentQuestion {
    final q = _quiz;
    if (q == null || q.questions.isEmpty) return null;
    if (_questionIndex < 0 || _questionIndex >= q.questions.length) return null;
    return q.questions[_questionIndex];
  }

  int get _questionCount => _quiz?.questions.length ?? 0;

  void _restartQuestionTimer() {
    _countdown?.cancel();
    final q = _currentQuestion;
    if (q == null || _submitted) return;

    setState(() {
      _secondsLeft = q.timerSeconds.clamp(5, 600);
    });

    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        _onTimerExpired();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onTimerExpired() {
    final q = _currentQuestion;
    if (q == null || _submitted) return;

    setState(() {
      _answers[q.id] = _answers[q.id] ?? 0;
    });

    if (_questionIndex < _questionCount - 1) {
      setState(() => _questionIndex++);
      _restartQuestionTimer();
    } else {
      setState(() {});
    }
  }

  void _selectOption(int index) {
    final q = _currentQuestion;
    if (q == null || _submitted) return;
    setState(() {
      _answers[q.id] = index;
    });
  }

  void _goPrevious() {
    if (_questionIndex <= 0 || _submitted) return;
    setState(() => _questionIndex--);
    _restartQuestionTimer();
  }

  void _goNext() {
    if (_submitted) return;
    final q = _currentQuestion;
    if (q == null) return;
    setState(() {
      _answers[q.id] = _answers[q.id] ?? 0;
    });
    if (_questionIndex < _questionCount - 1) {
      setState(() => _questionIndex++);
      _restartQuestionTimer();
    }
  }

  bool get _onLastQuestion => _questionIndex >= _questionCount - 1;

  Future<void> _submit() async {
    if (_submitting || _submitted || _quiz == null) return;

    final quiz = _quiz!;
    final displayTitle = widget.quizTitle?.trim().isNotEmpty == true
        ? widget.quizTitle!.trim()
        : quiz.title;

    final validated = QuizSubmitValidator.validateAndBuild(
      questions: quiz.questions,
      answersByQuestionId: _answers,
    );
    if (validated.errorMessage != null) {
      if (!mounted) return;
      showTonedSnackBar(
        context,
        validated.errorMessage!,
        tone: AppSnackBarTone.warning,
        duration: const Duration(seconds: 6),
      );
      return;
    }

    final payload = validated.answers!;

    setState(() => _submitting = true);
    _countdown?.cancel();

    try {
      final result = await ref.read(attemptRepositoryProvider).submitAttempt(
            quizId: quiz.id,
            answers: payload,
          );
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _submitting = false;
      });
      ref.invalidate(activeQuizzesProvider);

      context.goNamed(
        RouteNames.quizResult,
        pathParameters: {'quizId': quiz.id},
        extra: QuizResultArgs(
          quizId: quiz.id,
          quizTitle: displayTitle,
          totalQuestions: quiz.questions.length,
          score: result.score,
          attemptId: result.attemptId,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final formatted = formatApiException(e);

      if (e.statusCode == 409) {
        setState(() => _submitted = true);
        context.goNamed(
          RouteNames.quizResult,
          pathParameters: {'quizId': quiz.id},
          extra: QuizResultArgs(
            quizId: quiz.id,
            quizTitle: displayTitle,
            totalQuestions: quiz.questions.length,
            conflictMessage: formatted,
          ),
        );
        return;
      }

      showApiExceptionSnackBar(context, e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.quizTitle?.trim().isNotEmpty == true
        ? widget.quizTitle!.trim()
        : (_quiz?.title ?? 'Quiz');
    final textTheme = Theme.of(context).textTheme;

    if (_pendingResultNavigation) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(title: Text(title)),
        body: const AppLoadingIndicator(message: 'Opening your results…'),
      );
    }

    if (_loadingQuiz) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(title: Text(title)),
        body: const AppLoadingIndicator(message: 'Loading quiz…'),
      );
    }

    if (_loadFailure != null) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(title),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: AppErrorStateView(
                      title: 'Could not load quiz',
                      error: _loadFailure!,
                      onRetry: _resolveQuizFromApi,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.orange,
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _currentQuestion;
    if (q == null || _quiz == null) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(
            'No questions',
            style: TextStyle(color: context.palette.textSecondary),
          ),
        ),
      );
    }

    final selected = _answers[q.id];
    final totalSec = q.timerSeconds.clamp(5, 600);
    final progress = totalSec > 0 ? _secondsLeft / totalSec : 0.0;

    return PopScope(
      canPop: !_submitting,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: context.palette.background,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _submitting ? null : () => context.pop(),
              ),
              title: Text(title),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Question ${_questionIndex + 1} of $_questionCount',
                              style: textTheme.labelLarge?.copyWith(
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '$_secondsLeft s',
                            style: textTheme.titleSmall?.copyWith(
                              color: context.palette.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: context.palette.card,
                          color: context.palette.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          q.questionText,
                          style: textTheme.titleMedium?.copyWith(
                            color: context.palette.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(q.options.length, (i) {
                          final opt = q.options[i];
                          final isOn = selected != null && selected == i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: context.palette.card,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap:
                                    _submitted ? null : () => _selectOption(i),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isOn
                                          ? context.palette.orange
                                          : context.palette.textMuted
                                              .withOpacity(0.35),
                                      width: isOn ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isOn
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: isOn
                                            ? context.palette.orange
                                            : context.palette.textMuted,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: context.palette.textPrimary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        if (_questionIndex > 0)
                          OutlinedButton(
                            onPressed: (_submitting || _submitted)
                                ? null
                                : _goPrevious,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.palette.emerald,
                              side: BorderSide(color: context.palette.emerald),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Previous'),
                          ),
                        if (_questionIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _onLastQuestion
                              ? FilledButton(
                                  onPressed: (_submitting || _submitted)
                                      ? null
                                      : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: context.palette.orange,
                                    foregroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: _submitting
                                      ? const AppButtonProgress()
                                      : const Text('Submit quiz'),
                                )
                              : FilledButton(
                                  onPressed: (_submitting || _submitted)
                                      ? null
                                      : _goNext,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: context.palette.orange,
                                    foregroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: const Text('Next'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_submitting)
            const Positioned.fill(
              child: Material(
                color: Color(0x99000000),
                child: AppLoadingIndicator(
                  message: 'Submitting your answers…',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
