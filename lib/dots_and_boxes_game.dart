// ignore_for_file: avoid_print

import 'dart:core';
import 'package:dots_and_boxes/utils.dart';
import 'package:flutter/material.dart';

import 'player.dart';
import 'box.dart';
import 'dot.dart';
import 'line.dart';
import 'draw_boxes.dart';
import 'draw_dots.dart';

enum Direction { n, e, s, w }

enum Who { nobody, p1, p2 }

typedef Coord = (int x, int y);

const dotSizeFactor = 1 / 6;
const halfDotSizeFactor = 1 / 12;

int numberOfDots = 20;
late final int dotsHorizontal;
late final int dotsVertical;

final Map<Who, Player> players = {
  Who.nobody: Player(Colors.transparent),
  Who.p1: Player(Colors.orange),
  Who.p2: Player(Colors.blue)
};

class DotsAndBoxesGame extends StatefulWidget {
  const DotsAndBoxesGame({super.key});

  @override
  State<DotsAndBoxesGame> createState() => _DotsAndBoxesGame();
}

class _DotsAndBoxesGame extends State<DotsAndBoxesGame> {
  late final Set<Dot> dots; // These are always displayed.
  late final Set<Line> lines; // These are only displayed if drawn.
  late final Set<Box> boxes; // These are only displayed if closed.

  @override
  void initState() {
    super.initState();

    var dimChoices = getDimensionChoices(numberOfDots);
    print('Dimension choices are: $dimChoices');

    var dims = dimChoices.entries.where((dim) => dim.value.$1 * dim.value.$2 >= numberOfDots).first;
    numberOfDots = dims.key;
    dotsHorizontal = dims.value.$1;
    dotsVertical = dims.value.$2;
    print('Nbr of dots set to $numberOfDots, dimensions set to ($dotsHorizontal, $dotsVertical)');

    dots = {};
    for (int x = 0; x < dotsHorizontal; x++) {
      for (int y = 0; y < dotsVertical; y++) {
        dots.add(Dot((x, y)));
      }
    }

    boxes = {};
    lines = {};
    final List<Dot> boxDots = [];
    for (int x = 0; x < dotsHorizontal - 1; x++) {
      for (int y = 0; y < dotsVertical - 1; y++) {
        Box box = Box((x, y));
        var nw = dots.where((dot) => dot.position == (x, y)).single;
        var ne = dots.where((dot) => dot.position == (x + 1, y)).single;
        var se = dots.where((dot) => dot.position == (x + 1, y + 1)).single;
        var sw = dots.where((dot) => dot.position == (x, y + 1)).single;

        boxDots.add(nw);
        boxDots.add(ne);
        boxDots.add(se);
        boxDots.add(sw);

        for (final dot in boxDots) {
          dot.boxes.add(box);
        }

        // Create lines that surround the box:
        var n = Line(nw.position, ne.position);
        var e = Line(ne.position, se.position);
        var s = Line(sw.position, se.position);
        var w = Line(nw.position, sw.position);

        // Add them to global set of lines (ignoring rejection if any already exist):
        lines.add(n);
        lines.add(e);
        lines.add(s);
        lines.add(w);

        // Add the ones that ended up in the global set to the box:
        box.lines[lines.where((line) => line == n).single] = Direction.n;
        box.lines[lines.where((line) => line == e).single] = Direction.e;
        box.lines[lines.where((line) => line == s).single] = Direction.s;
        box.lines[lines.where((line) => line == w).single] = Direction.w;

        boxes.add(box);
      }
    }

    resetGame();
  }

  void resetGame() {
    for (final line in lines) {
      line.drawer = Who.nobody;
    }
    for (final box in boxes) {
      box.closer = Who.nobody;
    }

    // TODO: For testing, close all the boxes:
    Future.delayed(const Duration(seconds: 1)).then((_) => closeSomeBoxes(percentage: 100));

    debugPrint('dots={\n  ${dots.join(',\n  ')}\n}');
    debugPrint('lines={\n  ${lines.join(',\n  ')}\n}');
    debugPrint('boxes={\n  ${boxes.join(',\n\n  ')} \n }');
  }

  Future<void> closeSomeBoxes({int percentage = 100}) async {
    // TODO: For testing, close all the boxes:
    var player = Who.p1;
    // var linesDrawn = 0;

    var shuffled = lines.where((line) => line.drawer == Who.nobody).toList()..shuffle();
    print('percentage is $percentage');
    print('taking ${(shuffled.length * percentage / 100).ceil()} out of ${shuffled.length} lines');
    for (final line in shuffled.take((shuffled.length * percentage / 100).ceil())) {
      line.drawer = player;
      print('Drew $line as $player');
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});

      for (final box in boxes.where((box) => box.lines.containsKey(line))) {
        // print('Inspecting Box($box)');

        if (box.isClosed()) {
          box.closer = player;
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        }
      }

      // Switch players:
      if (player == Who.p1) {
        player = Who.p2;
      } else {
        player = Who.p1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      return Stack(children: [
        DrawBoxes(width, height, boxes),
        DrawDots(width, height, dots),
      ]);
    });
  }
}
