// lib/domain/repositories/swap_repository.dart
import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/data/domain/entities/swap.dart';
// import 'package:book_swap/core/errors/failures.dart';
// import 'package:book_swap/domain/entities/swap.dart';
import 'package:dartz/dartz.dart';

abstract class SwapRepository {
  Future<Either<Failure, SwapEntity>> initiateSwap(SwapEntity swap);
  Future<Either<Failure, Unit>> updateSwapStatus(String swapId, SwapStatus status);
  Future<Either<Failure, Unit>> updateSwap(SwapEntity swap); // For other updates if needed
  Stream<Either<Failure, List<SwapEntity>>> getMyInitiatedSwaps(String userId); // Offers I made
  Stream<Either<Failure, List<SwapEntity>>> getSwapsForMyBooks(String userId); // Offers on my books
  Future<Either<Failure, SwapEntity>> getSwapById(String swapId);
}