import java.util.*;

public class PixelType {
  private boolean player;
  private boolean border;
  
  public List<Particle> particles;
  public List<Particle> particlesNext;

  
  public PixelType() {
    this.player = false;
    this.border = false;
    
    this.particles = new ArrayList<Particle>();
    this.particlesNext = new ArrayList<Particle>();
  }
  
  public void resetParticles() {
    particles = particlesNext;
    this.particlesNext = new ArrayList<Particle>();
  }
  
  public boolean isPlayer() {
    return this.player;
  }
  
  public boolean isBorder() {
    return this.border;
  }
  
  public void setPlayer(boolean player) {
    this.player = player;
  }
  
  public void setBorder(boolean border) {
    this.border = border;
  }
}
