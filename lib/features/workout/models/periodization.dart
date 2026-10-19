class PeriodizationPhase {
  final int phaseNumber;
  final String title;
  final String durationRange;
  final int startWeek;
  final int endWeek;
  final String focusDescription;
  final String repRangeGuide;
  final String rirGuide;
  final String pelvicStrategy;
  final List<String> keyRules;

  const PeriodizationPhase({
    required this.phaseNumber,
    required this.title,
    required this.durationRange,
    required this.startWeek,
    required this.endWeek,
    required this.focusDescription,
    required this.repRangeGuide,
    required this.rirGuide,
    required this.pelvicStrategy,
    required this.keyRules,
  });

  static const List<PeriodizationPhase> allPhases = [
    PeriodizationPhase(
      phaseNumber: 1,
      title: 'Neuromuscular Re-alignment & Stretch-Mediated Hypertrophy',
      durationRange: 'Weeks 1 - 8',
      startWeek: 1,
      endWeek: 8,
      focusDescription:
          'Establish strict posterior pelvic tilt under load, eliminate hip flexor dominance, and rebuild neuromuscular mind-muscle connection in lengthened muscle positions.',
      repRangeGuide: '8 - 15 Reps (Compound: 8-10 | Isolation: 12-15)',
      rirGuide: '1 - 2 RIR (Leave 1-2 reps in reserve, focus on immaculate form)',
      pelvicStrategy: 'Mandatory 10-min pre-workout APT drills before every session. Zero lumbar arching permitted on presses or squats.',
      keyRules: [
        'Perform 2-second eccentric phase on all compound lifts.',
        'Actively tuck pelvis at peak lockout on Hip Thrusts and RDLs.',
        'Log baseline load for all 5 training days.',
        'Deload on Week 8 if neuromuscular fatigue manifests.',
      ],
    ),
    PeriodizationPhase(
      phaseNumber: 2,
      title: 'Mechanical Tension Overload',
      durationRange: 'Weeks 9 - 16',
      startWeek: 9,
      endWeek: 16,
      focusDescription:
          'Drive progressive overload through increased mechanical tension, adding +2 sets per muscle group each week while enforcing ribcage-to-pelvis stacking.',
      repRangeGuide: '6 - 10 Reps on Compounds | 10 - 15 on Isolations',
      rirGuide: '1 RIR on compounds, 0 RIR (technical failure) on isolation sets',
      pelvicStrategy: 'Maintain brace; use intra-abdominal pressure without flaring the lower rib cage.',
      keyRules: [
        '+2 sets added progressively per muscle group weekly.',
        'Increase load whenever target top reps are hit with perfect RIR.',
        'Keep rest intervals strict: 120s on primary compounds, 75-90s on secondary.',
        'Week 16 scheduled reactive deload.',
      ],
    ),
    PeriodizationPhase(
      phaseNumber: 3,
      title: 'Metabolic Density & Antagonist Supersets',
      durationRange: 'Weeks 17 - 24',
      startWeek: 17,
      endWeek: 24,
      focusDescription:
          'Maximal hypertrophy density through antagonist supersets and lengthened partial repetitions on final sets to recruit high-threshold motor units.',
      repRangeGuide: '10 - 20 Reps + Lengthened Partials on final set',
      rirGuide: '0 RIR (Absolute muscular failure on isolations)',
      pelvicStrategy: 'Protect lumbar erectors by maintaining anti-extension bracing even under deep metabolic burn.',
      keyRules: [
        'Lengthened partials performed on the last set of lat pulldowns, curls, and leg extensions.',
        'Antagonist pairing: Biceps/Triceps and Quad/Hamstrings back-to-back.',
        'High metabolic metabolite accumulation & peak cell volumization.',
      ],
    ),
  ];
}
