// Dot Matrix Portrait with Upward-Push Effect
// Mimics the effect from ubadahsabbagh.com

int cols = 100;  // Number of columns in the grid
int rows = 100;  // Number of rows in the grid
float spacing = 6;  // Space between particles
Particle[][] particles;  // 2D array of particles
PImage img;  // Source image

void setup() {
  size(800, 800, P2D);
  background(0);
  
  // Load and resize the image to match grid dimensions
  img = loadImage("ellis2.png");  // Using steve.jpg as specified
  img.resize(cols, rows);
  
  // Initialize particle grid
  particles = new Particle[cols][rows];
  
  // Create particles based on image brightness
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Calculate grid position
      float x = width / 2 - cols * spacing / 2 + i * spacing;
      float y = height / 2 - rows * spacing / 2 + j * spacing;
      
      // Get brightness value from image
      float b = brightness(img.get(i, j));
      
      // Create particle with brightness threshold
      if (b > 50) {  // Only create particles for brighter areas
        particles[i][j] = new Particle(x, y, b);
      } else {
        particles[i][j] = null;  // No particle for dark areas
      }
    }
  }
}

void draw() {
  // Clear with semi-transparent black for subtle trails
  fill(0, 40);
  rect(0, 0, width, height);
  
  // Enable blending for glow effect
  blendMode(ADD);
  
  // Update and display particles
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (particles[i][j] != null) {
        particles[i][j].interactWithNeighbors(i, j);
        particles[i][j].update();
        particles[i][j].display();
      }
    }
  }
  
  // Reset blend mode
  blendMode(BLEND);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("portrait-####.png");
    println("Frame saved!");
  }
}

class Particle {
  PVector pos;       // Current position
  PVector origin;    // Original position
  PVector vel;       // Velocity
  PVector acc;       // Acceleration
  float brightness;  // Brightness from image
  float size;        // Particle size
  
  // Physics parameters
  float influenceRadius = 160;    // Mouse influence range (increased further)
  float bounceRadius = spacing * 1.0;  // Collision distance (reduced)
  float springStrength = 0.13; // snappier return
  
  Particle(float x, float y, float b) {
    pos = new PVector(x, y);
    origin = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    brightness = b;
    
    // Vary particle size based on brightness
    size = map(brightness, 0, 255, 1.5, 3.5);
  }
  
  void update() {
    // Calculate mouse influence (dome-like upward push)
    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(pos, mouse);
    float d = dir.mag();
    
    if (d < influenceRadius && d > 5) {
      // Calculate normalized distance for smooth falloff
      float normalizedDist = d / influenceRadius;
      
      // Enhanced dome-shaped force field (stronger in center, weaker at edges)
      float forceMagnitude = 7.0 * pow(1.0 - normalizedDist, 1.8);
      forceMagnitude = constrain(forceMagnitude, 0, 7.0);
      
      // Force is primarily upward, with a small outward component
      PVector force = new PVector();
      
      // The main upward component (always negative y - upward) - increased strength
      force.y = -forceMagnitude * 0.9;
      
      // Small outward component based on relative position - reduced
      force.x = dir.x / d * forceMagnitude * 0.1;
      
      applyForce(force);
    }
    
    // Spring force to return to original position
    PVector spring = PVector.sub(origin, pos);
    spring.mult(springStrength);
    applyForce(spring);
    
    // Apply physics
    vel.add(acc);
    vel.mult(0.92); // slightly tighter damping
    pos.add(vel);
    acc.mult(0);     // Reset acceleration
  }
  
  void interactWithNeighbors(int i, int j) {
    // Check neighboring particles for collisions
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        // Skip self
        if (di == 0 && dj == 0) continue;
        
        int ni = i + di;
        int nj = j + dj;
        
        // Check bounds
        if (ni >= 0 && ni < cols && nj >= 0 && nj < rows) {
          Particle neighbor = particles[ni][nj];
          
          // Skip empty cells
          if (neighbor == null) continue;
          
          // Calculate distance
          float d = PVector.dist(pos, neighbor.pos);
          
          // Apply soft repulsion if too close
          if (d < bounceRadius && d > 0) {
            PVector repel = PVector.sub(pos, neighbor.pos);
            repel.normalize();
            float strength = map(d, 0, bounceRadius, 0.05, 0);
            repel.mult(strength);
            applyForce(repel);
          }
        }
      }
    }
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  void display() {
    noStroke();
  
  
    // Core dot
    fill(255, 255);
    ellipse(pos.x, pos.y, size, size);
  }
}
