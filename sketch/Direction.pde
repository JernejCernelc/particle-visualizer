public enum Direction {
  UP(0),
  RIGHT(1),
  DOWN(2),
  LEFT(3);
  
  private final int index;
  
  private Direction(int index) {
    this.index = index;
  }
  
  public int getIndex() {
    return this.index;
  }
}
