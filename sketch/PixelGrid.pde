public class PixelGrid {
  private PixelType[][] grid;
  private Object[][] syncGrid;
  public Particle[] particles;
  public int w;
  public int h;
    
  public PixelGrid(int w, int h, int numberOfParticles) {
    this.w = w;
    this.h = h;
    this.grid = new PixelType[w][h];
    this.syncGrid = new Object[w][h];
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        this.grid[x][y] = new PixelType();
        this.syncGrid[x][y] = new Object();
        if(x == 0 || y == 0 || x == w - 1 || y == h - 1) {
          updateBorderPixelType(x, y, true);
        }
      }
    }
    this.particles = new Particle[numberOfParticles];
    for(int i = 0; i < this.particles.length; i++) {
      this.particles[i] = new Particle(i+1, (int)random(0, w-1), (int)random(0, h-1));
    }
  }
  
  public void calculateParticles() {
    for(Particle particle : particles) {
      particle.clearAcceleration();

      //interaction with player
      if(getPixelType(particle.gridX, particle.gridY).isPlayer()) {
        float[] scan;
        int level = 1;
        do {
          scan = scanLevel(level, particle.gridX, particle.gridY);
          level++;
        } while(isEmpty(scan) && level < 10);
        
        particle.addAcceleration(Direction.UP, scan[Direction.UP.getIndex()]);
        particle.addAcceleration(Direction.LEFT, scan[Direction.RIGHT.getIndex()]);
        particle.addAcceleration(Direction.DOWN, scan[Direction.DOWN.getIndex()]);
        particle.addAcceleration(Direction.RIGHT, scan[Direction.LEFT.getIndex()]);
      }
      
      //interaction with border
      if(getPixelType(particle.gridX, particle.gridY).isBorder()) {
        particle.invertSpeed(particle.gridX == 0 || particle.gridX == w-1);
      }
      
      //interaction with other particles
      //bounce(particle);
      
      //updateParticlePixelType(particle, false);
      particle.updatePosition(w, h);
      //addParticlePixelType(particle);
    }
  }
  
  private boolean isEmpty(float[] scan) {
    for(int i = 0; i < 4; i++) {
      if(scan[i] > 0.0) {
        return false;
      }
    }
    return true;
  }
  
  private void bounce(Particle particle) {
    if(grid[particle.gridX][particle.gridY].particles.size() > 1) {
      float speedX = 0.0;
      float speedY = 0.0;
      int numberOfCollisions = 0;
      for(Particle p : grid[particle.gridX][particle.gridY].particles) {
        if(p.id != particle.id) {
          speedX += -p.speedX;
          speedY += -p.speedY;
          //numberOfCollisions++;
        } else {
          speedX += p.speedX;
          speedY += p.speedY;
        }
        numberOfCollisions++;
      }
      particle.speedX = speedX/numberOfCollisions;
      particle.speedY = speedY/numberOfCollisions;
    }
  }
  
  private float[] scanLevel(int level, int x, int y) {
    float[] acc = new float[] {0.0, 0.0, 0.0, 0.0};
    int leftX = x - level;
    int rightX = x + level;
    int topY = y - level;
    int botY = y + level;
    
    if(topY >= 0) {
      for(int i = max(leftX, 0); i <= min(rightX, w-1); i++) {
        //println("(1)"+i+","+topY);
        if(!getPixelType(i, topY).isPlayer()) {
          float[] dis = manhattanDistance(x, y, i, topY);
          acc[Direction.UP.getIndex()] += dis[1];
          if(i < x) {
            acc[Direction.LEFT.getIndex()] += dis[0];
          } else if(i > x) {
            acc[Direction.RIGHT.getIndex()] += dis[0];
          }
        }
      }
    }
    
    if(rightX < w) {
      for(int j = max(topY+1, 0); j <= min(botY-1, h-1); j++) {
        //println("(2)"+rightX+","+j);
        if(!getPixelType(rightX, j).isPlayer()) {
          float[] dis = manhattanDistance(x, y, rightX, j);
          acc[Direction.RIGHT.getIndex()] += dis[0];
          if(j < y) {
            acc[Direction.UP.getIndex()] += dis[1];
          } else if(j > y) {
            acc[Direction.DOWN.getIndex()] += dis[1];
          }
        }
      }
    }
    
    if(botY < h) {
      for(int i = max(leftX, 0); i <= min(rightX, w-1); i++) {
        //println("(3)"+i+","+botY);
        if(!getPixelType(i, botY).isPlayer()) {
          float[] dis = manhattanDistance(x, y, i, botY);
          acc[Direction.DOWN.getIndex()] += dis[1];
          if(i < x) {
            acc[Direction.LEFT.getIndex()] += dis[0];
          } else if(i > x) {
            acc[Direction.RIGHT.getIndex()] += dis[0];
          }
        }
      }
    }
    
    if(leftX >= 0) {
      for(int j = max(topY+1, 0); j <= min(botY-1, h-1); j++) {
        //println("(4)"+leftX+","+j);
        if(!getPixelType(leftX, j).isPlayer()) {
          float[] dis = manhattanDistance(x, y, leftX, j);
          acc[Direction.LEFT.getIndex()] += dis[0];
          if(j < y) {
            acc[Direction.UP.getIndex()] += dis[1];
          } else if(j > y) {
            acc[Direction.DOWN.getIndex()] += dis[1];
          }
        }
      }
    }
    return acc;
  }
  
  private float[] manhattanDistance(int x, int y, int x2, int y2) {
    float dis[] = new float[] {0.0, 0.0};
    
    dis[0] = abs(x2 - x)/2;
    dis[1] = abs(y2 - y)/2;
    
    return dis;
  }
  
    public void updatePlayerPixelType(int x, int y, boolean val) {
    synchronized(syncGrid[x][y]) {
      grid[x][y].setPlayer(val);
    }
  }
  
  public void resetParticlesPixelType(int x, int y) {
    synchronized(syncGrid[x][y]) {
      grid[x][y].resetParticles();
    }
  }
  
  public void addParticlePixelType(Particle p) {
    synchronized(syncGrid[p.gridX][p.gridY]) {
      grid[p.gridX][p.gridY].particlesNext.add(p);
    }
  }
  
  public void updateBorderPixelType(int x, int y, boolean val) {
    synchronized(syncGrid[x][y]) {
      grid[x][y].setBorder(val);
    }
  }
  
  public PixelType getPixelType(int x, int y) {
    synchronized(syncGrid[x][y]) {
      return grid[x][y];
    }
  }
}
