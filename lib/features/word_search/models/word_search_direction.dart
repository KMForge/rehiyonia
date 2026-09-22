enum WordSearchDirection {
  horizontalForward(0, 1),
  horizontalBackward(0, -1),
  verticalDown(1, 0),
  verticalUp(-1, 0),
  diagonalDownRight(1, 1),
  diagonalUpRight(-1, 1),
  diagonalDownLeft(1, -1),
  diagonalUpLeft(-1, -1);

  const WordSearchDirection(this.dRow, this.dCol);

  final int dRow;
  final int dCol;

  bool get isHorizontal => dRow == 0 && dCol != 0;
  bool get isVertical => dCol == 0 && dRow != 0;
  bool get isDiagonal => dRow != 0 && dCol != 0;
}
