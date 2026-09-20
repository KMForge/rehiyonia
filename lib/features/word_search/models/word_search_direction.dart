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
}
