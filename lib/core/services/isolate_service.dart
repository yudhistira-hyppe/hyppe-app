// import 'dart:io' show Platform;
import 'package:computer/computer.dart';

class IsolateService {
  static final computers = Computer.shared();

  Future<void> turnOnWorkers({int worker = 2}) async {
    // print('Number of processor ${Platform.localHostname} => ${Platform.numberOfProcessors}');
    // await computers.turnOn(verbose: true, workersCount: worker);
  }

  Future<void> turnOffWorkers() async {
    // await computers.turnOff();
  }

  bool workerActive() => computers.isRunning;

  Future<Result> computeFunction<Param, Result>({required Function fn, required Param param}) async {
    final _resultComputation = await computers.compute<Param, Result>(fn, param: param);

    return _resultComputation;
  }
}
