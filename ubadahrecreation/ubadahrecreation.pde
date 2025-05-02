// Particle animation by Ellis Simmons
// Springy, parabolic push with bouncing particles using a white block

int cols = 75;
int rows = 75;
float spacing = 6;

Particle[][] particles;

void setup() {
  size(600, 600);
  particles = new Particle[cols][rows];

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = width / 2 - cols * spacing / 2 + i * spacing;
      float y = height / 2 - rows * spacing / 2 + j * spacing;

      float b = 255; // all white brightness
      particles[i][j] = new Particle(x, y, b);
    }
  }
}

void draw() {
  background(20);

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      particles[i][j].interactWithNeighbors(i, j);
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

    if (d < influenceRadius) {
      dir.normalize();
      float force = pow(max(0, 1 - sq(d / influenceRadius)), 2); // parabolic force
      dir.mult(force * 3);
      applyForce(dir);
    }

    PVector returnForce = PVector.sub(origin, pos);
    returnForce.mult(0.08);
    applyForce(returnForce);

    PVector jitter = new PVector(random(-0.05, 0.05), random(-0.05, 0.05));
    applyForce(jitter);

    vel.add(acc);
    vel.mult(0.9);
    pos.add(vel);
    acc.mult(0);
  }

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
            repel.mult((bounceRadius - d) * 0.02);
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
