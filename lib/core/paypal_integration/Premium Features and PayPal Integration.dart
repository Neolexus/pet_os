import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_health_companion/features/premium/domain/usecases/verify_premium_status.dart';
import 'package:pet_health_companion/features/premium/domain/usecases/process_payment.dart';

part 'premium_event.dart';
part 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final VerifyPremiumStatus verifyPremiumStatus;
  final ProcessPayment processPayment;

  PremiumBloc({
    required this.verifyPremiumStatus,
    required this.processPayment,
  }) : super(PremiumInitial()) {
    on<CheckPremiumStatus>(_onCheckPremiumStatus);
    on<PurchasePremium>(_onPurchasePremium);
  }

  Future<void> _onCheckPremiumStatus(
    CheckPremiumStatus event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      final isPremium = await verifyPremiumStatus.execute();
      emit(PremiumStatusLoaded(isPremium: isPremium));
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onPurchasePremium(
    PurchasePremium event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PaymentProcessing());
    try {
      final success = await processPayment.execute(event.amount);
      if (success) {
        emit(PaymentSuccess());
      } else {
        emit(PaymentFailed('Payment processing failed'));
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }
}