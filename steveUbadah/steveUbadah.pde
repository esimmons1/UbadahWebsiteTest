// Particle animation by Ellis Simmons
// Mimics a springy, parabolic push effect with particles that bounce off each other

int cols = 75;
int rows = 75;
float spacing = 6;

Particle[][] particles;
PImage img;

void setup() {
  size(600, 600);
  img = loadImage("ellis2.png");
  img.resize(cols, rows);

  particles = new Particle[cols][rows];

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = width / 2 - cols * spacing / 2 + i * spacing;
      float y = height / 2 - rows * spacing / 2 + j * spacing;
      float b = brightness(img.get(i, j));
      particles[i][j] = new Particle(x, y, b);
    }
  }
}

void draw() {
  background(20);

  // Update and show each particle
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      particles[i][j].interactWithNeighbors(i, j); // bounce from nearby particles
      particles[i][j].update();
      particles[i][j].show();
    }
  }
}

class Particle {
  PVector pos, origin, vel, acc;
  float brightnessValue;
  float influenceRadius = 100;
  float bounceRadius = spacing * 1.5;

  Particle(float x, float y, float b) {
    pos = new PVector(x, y);
    origin = new PVector(x, y);
    vel = new PVector();
    acc = new PVector();
    brightnessValue = b;
  }

  void update() {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(pos, mouse);
    float d = dir.mag();

    // Parabolic push effect
    if (d < influenceRadius) {
      dir.normalize();
      float force = -log(d / influenceRadius); // parabolic shape
      dir.mult(force * 1.5); // push strength
      applyForce(dir);
    }

    // Spring back to original position (stiff)
    PVector returnForce = PVector.sub(origin, pos);
    returnForce.mult(0.5); // faster spring-back
    applyForce(returnForce);

    // Small random jitter
    PVector jitter = new PVector(random(-0.05, 0.05), random(-0.05, 0.05));
    applyForce(jitter);

    vel.add(acc);
    vel.mult(0.9); // damping
    pos.add(vel);
    acc.mult(0);
  }

  // Soft bounce off nearby particles
  void interactWithNeighbors(int i, int j) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        int ni = i + dx;
        int nj = j + dy;
        if (ni >= 0 && nj >= 0 && ni < cols && nj < rows && (dx != 0 || dy != 0)) {
          Particle other = particles[ni][nj];
          float d = PVector.dist(pos, other.pos);
          if (d < bounceRadius && d > 0) {
            PVector repel = PVector.sub(pos, other.pos);
            repel.normalize();
            repel.mult((bounceRadius - d) * 0.02); // soft push
            applyForce(repel);
          }
        }
      }
    }
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void show() {
    noStroke();
    float col = map(brightnessValue, 0, 255, 0, 255);
    fill(col);
    ellipse(pos.x, pos.y, 4, 4);
  }
}
