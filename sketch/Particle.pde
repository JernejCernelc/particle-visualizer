public class Particle implements Comparable<Particle> {
  public int id;
  
  public float x;
  public float y;
  public int gridX;
  public int gridY;
  public float speedX;
  public float speedY;
  public float acceleration[];
  
  private float maxSpeed; //3.0
  private float minSpeedX; //3.0
  private float minSpeedY; //3.0
  private float airResistance = 0.03; //0.03
  private float maxAcceleration = 0.5;
  
  private boolean gravity = false;
  private float gravityAcceleration = 0.1;
  
  private float colorTo;
  private float colorFrom;
  
  public Particle(int id, int x, int y) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.gridX = x;
    this.gridY = y;
    maxSpeed = random(1.0, 3.0);
    minSpeedX = random(0.1, 0.5);
    minSpeedY = random(0.1, 0.5);
    this.speedX = random(-maxSpeed, maxSpeed);
    this.speedY = random(-maxSpeed, maxSpeed);;
    this.acceleration = new float[4];
    for(int i = 0; i < 4; i++) {
      this.acceleration[i] = 0;
    }
    
    this.colorTo = 30;
    this.colorFrom = 235-(60*maxSpeed);
  }
  
  public void clearAcceleration() {
    for(int i = 0; i < 4; i++) {
      this.acceleration[i] = 0;
    }
    
    if(gravity) {
      this.acceleration[Direction.DOWN.getIndex()] = constrain(this.acceleration[Direction.DOWN.getIndex()] + gravityAcceleration, 0, maxAcceleration);
    }
  }
  
  public void addAcceleration(Direction direction, float acceleration) {
    this.acceleration[direction.getIndex()] = constrain(this.acceleration[direction.getIndex()] + acceleration, 0, maxAcceleration);
  }
  
  public void invertSpeed(boolean side) {
    if(side) {
      speedX = -speedX;
    } else {
      speedY = -speedY;
    }
  }
  
  public void updatePosition(int w, int h) {
    speedX = constrain(speedX + this.acceleration[Direction.LEFT.getIndex()] - this.acceleration[Direction.RIGHT.getIndex()], -maxSpeed, maxSpeed);
    speedY = constrain(speedY + this.acceleration[Direction.DOWN.getIndex()] - this.acceleration[Direction.UP.getIndex()], -maxSpeed, maxSpeed);
    if(speedX > 0) {
      speedX = constrain(speedX - airResistance, minSpeedX, maxSpeed);
    } else {
      speedX = constrain(speedX + airResistance, -maxSpeed, -minSpeedX);
    }
    if(speedY > 0) {
      speedY = constrain(speedY - airResistance, minSpeedY, maxSpeed);
    } else {
      speedY = constrain(speedY + airResistance, -maxSpeed, -minSpeedY);
    }
    this.x = constrain(this.x + speedX,0 , w - 1);
    this.y = constrain(this.y + speedY,0 , h - 1);
    this.gridX = Math.round(this.x);
    this.gridY = Math.round(this.y);
  }
  
  public int mapSpeedToColor() {
    return (int)map(abs(speedX)+abs(speedY), 0, maxSpeed*2, colorFrom, colorTo);
  }
  
  public int   mapSpeedToSize(float maxPixelSize) {
    return (int)map(abs(speedX)+abs(speedY), 0, maxSpeed*2, maxPixelSize*2-(maxSpeed), maxPixelSize);
  }
    
  int compareTo(Particle p) {
    if(this.id == p.id) {
      return 0;
    } else if(this.id > p.id) {
      return 1;
    } else {
      return -1;
    }
  }
}
