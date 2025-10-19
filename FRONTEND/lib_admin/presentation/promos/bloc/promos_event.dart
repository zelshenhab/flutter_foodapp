import 'package:equatable/equatable.dart';
import '../../../data/repos/promos_repo.dart';

abstract class PromosEvent extends Equatable {
  const PromosEvent();
  @override
  List<Object?> get props => [];
}

class PromosLoaded extends PromosEvent {
  const PromosLoaded();
}

class PromoAdded extends PromosEvent {
  final AdminPromo promo;
  const PromoAdded(this.promo);
  @override
  List<Object?> get props => [promo];
}

class PromoUpdated extends PromosEvent {
  final AdminPromo promo;
  const PromoUpdated(this.promo);
  @override
  List<Object?> get props => [promo];
}

class PromoDeleted extends PromosEvent {
  final String id;
  const PromoDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class PromoToggled extends PromosEvent {
  final String id;
  final bool active;
  const PromoToggled(this.id, this.active);
  @override
  List<Object?> get props => [id, active];
}
