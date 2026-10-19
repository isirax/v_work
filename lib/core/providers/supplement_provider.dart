import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/supplements/models/supplement_item.dart';

enum MultivitaminChoice {
  limitlessManMax,
  vit4everAZ,
}

class SupplementState {
  final List<SupplementItem> items;
  final MultivitaminChoice activeMultivitamin;
  final String? safetyWarningMessage;

  const SupplementState({
    required this.items,
    this.activeMultivitamin = MultivitaminChoice.limitlessManMax,
    this.safetyWarningMessage,
  });

  SupplementState copyWith({
    List<SupplementItem>? items,
    MultivitaminChoice? activeMultivitamin,
    String? safetyWarningMessage,
    bool clearWarning = false,
  }) {
    return SupplementState(
      items: items ?? this.items,
      activeMultivitamin: activeMultivitamin ?? this.activeMultivitamin,
      safetyWarningMessage: clearWarning ? null : (safetyWarningMessage ?? this.safetyWarningMessage),
    );
  }
}

final supplementProvider = NotifierProvider<SupplementNotifier, SupplementState>(SupplementNotifier.new);

class SupplementNotifier extends Notifier<SupplementState> {
  @override
  SupplementState build() {
    final list = _buildInitialList();
    final updatedList = _applyChoiceToList(list, MultivitaminChoice.limitlessManMax);
    return SupplementState(items: updatedList);
  }

  static List<SupplementItem> _buildInitialList() {
    return [
      // MORNING (08:00 AM)
      const SupplementItem(
        id: 'supp_multi_limitless',
        name: 'Limitless Man Max',
        dosage: '1 tablet with Meal 1 fats',
        timing: SupplementTiming.morning,
        mechanism: 'Full-spectrum micronutrient optimization with botanical bioflavonoids.',
        warning: 'MUTUALLY EXCLUSIVE: Cannot take with Vit4ever A-Z to prevent hypervitaminosis.',
        isMutuallyExclusive: true,
      ),
      const SupplementItem(
        id: 'supp_vit_d3',
        name: 'Vitamin D3 (Cholecalciferol)',
        dosage: '10,000 IU with Meal 1 fats',
        timing: SupplementTiming.morning,
        mechanism: 'Immune modulator, androgen receptor sensitivity, and bone mineral density.',
        warning: 'Must be ingested with dietary lipids (eggs/olive oil) for micellar uptake.',
      ),
      const SupplementItem(
        id: 'supp_omega_rx',
        name: 'Infinity Pharma Omega RX Plus',
        dosage: '2 softgels (High EPA/DHA)',
        timing: SupplementTiming.morning,
        mechanism: 'Systemic cellular inflammation reduction, joint lubrication, cardiovascular protection.',
      ),

      // POST-WORKOUT (05:30 PM)
      const SupplementItem(
        id: 'supp_creatine',
        name: 'Creatine Monohydrate',
        dosage: '5g in post-workout shake',
        timing: SupplementTiming.postWorkout,
        mechanism: 'Intracellular phosphocreatine replenishment, cellular volumization, peak rate of force development.',
      ),
      const SupplementItem(
        id: 'supp_whey_isolate',
        name: 'Whey Protein Isolate',
        dosage: '30g protein (1 scoop)',
        timing: SupplementTiming.postWorkout,
        mechanism: 'Rapid hyperaminoacidemia and mTORC1 stimulation during acute post-exercise sensitivity.',
      ),

      // EVENING (08:00 PM)
      const SupplementItem(
        id: 'supp_ashwagandha',
        name: 'Dozova Ashwagandha (KSM-66)',
        dosage: '1 capsule with Meal 3',
        timing: SupplementTiming.evening,
        mechanism: 'Down-regulates evening cortisol, supports thyroid homeostasis and deep sleep cycles.',
      ),

      // PRE-BED (10:30 PM)
      const SupplementItem(
        id: 'supp_magnesium',
        name: 'NOW Magnesium Glycinate',
        dosage: '200-400mg (30 min pre-bed)',
        timing: SupplementTiming.preBed,
        mechanism: 'GABAergic CNS sedation, relieves lumbar muscular hypertonicity from APT, deep slow-wave sleep.',
      ),
    ];
  }

  static List<SupplementItem> _applyChoiceToList(List<SupplementItem> current, MultivitaminChoice choice) {
    return current.map((item) {
      if (item.isMutuallyExclusive) {
        if (choice == MultivitaminChoice.limitlessManMax) {
          return const SupplementItem(
            id: 'supp_multi_limitless',
            name: 'Limitless Man Max',
            dosage: '1 tablet with Meal 1 fats',
            timing: SupplementTiming.morning,
            mechanism: 'Full-spectrum micronutrient optimization with botanical bioflavonoids.',
            warning: 'MUTUALLY EXCLUSIVE: Vit4ever Multivitamin A-Z is disabled to prevent hypervitaminosis.',
            isMutuallyExclusive: true,
          );
        } else {
          return const SupplementItem(
            id: 'supp_multi_vit4ever',
            name: 'Vit4ever Multivitamin A-Z',
            dosage: '1 tablet with Meal 1 fats',
            timing: SupplementTiming.morning,
            mechanism: 'Essential daily vitamins & minerals matrix from A to Zinc.',
            warning: 'MUTUALLY EXCLUSIVE: Limitless Man Max is disabled to prevent hypervitaminosis.',
            isMutuallyExclusive: true,
          );
        }
      }
      return item;
    }).toList();
  }

  void selectMultivitamin(MultivitaminChoice choice) {
    state = state.copyWith(
      activeMultivitamin: choice,
      items: _applyChoiceToList(state.items, choice),
    );
  }

  void toggleSupplement(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList(),
    );
  }

  void resetDay() {
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isCompleted: false)).toList(),
      clearWarning: true,
    );
  }

  void clearWarning() {
    state = state.copyWith(clearWarning: true);
  }
}
