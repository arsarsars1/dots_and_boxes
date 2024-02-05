import 'package:flutter/material.dart';

import 'game_size_slider.dart';

class CreateNewGameDialog<T> extends PopupRoute<T> {
  final void Function(int, int) createNewGame;
  int numPlayers = 2;
  int numDots = 12;
  bool createLocalGame = false;

  CreateNewGameDialog({required this.createNewGame});

  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Create New Game';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Text('Create New Game', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 30),
            Column(
              children: [
                DropdownMenu<int>(
                  initialSelection: 2,
                  requestFocusOnTap: false,
                  label: const Text("Number of Players"),
                  onSelected: (int? value) {
                    setState(() {
                      numPlayers = value!;
                    });
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 2, label: "2"),
                    DropdownMenuEntry(value: 3, label: "3"),
                    DropdownMenuEntry(value: 4, label: "4"),
                    DropdownMenuEntry(value: 5, label: "5"),
                  ],
                ),
                const SizedBox(height: 20),
                InputDecorator(
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Number of Dots'),
                    child: GameSizeSlider(setNumberOfDots: setNumDots, isEnabled: true)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          createNewGame(numDots, numPlayers);
                          Navigator.pop(context);
                        },
                        child: const Text("Create")),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          debugPrint('Creation of new game canceled.');
                          Navigator.pop(context);
                        },
                        child: const Text("Don't create")),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      debugPrint('Playing locally with shared device.');
                      // Todo: Start local-only game.
                    },
                    child: const Text("Create and play locally with shared device")),
              ],
            )
          ],
        ),
      ),
    );
  }

  void setNumDots(int numDots) {
    this.numDots = numDots;
  }
}
