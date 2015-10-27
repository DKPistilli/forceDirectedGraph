import ddf.minim.*;

//GLOBALS
Graph graph;
final float DAMPENING_FACTOR = .2;
final float EPSILON = 0.0000001;
final float COULOMB_K = 15;
final float HOOKE_K = .05;
final float MOUSE_K = .2;
boolean updating = true;

//color
final int red = 135;
final int green = 206;
final int blue = 250;

final int fill_red = 255;
final int fill_green = 127;
final int fill_blue = 36;

final int space_red = 255;
final int space_green = 255;
final int space_blue = 240;

final float ROTATION_DELTA = 0.002;

Minim m;
AudioPlayer s1;


PImage nebula_img;
ArrayList<PImage> planets;
final int NUM_PLANETS = 20;
int planetCounter = 0;

boolean rotateNebula = false;

boolean nebula = false;

PImage sparkle;

float rot = 0;


//framerate
int frames = 60;
final int MIN_FRAMERATE = 12;
final int MAX_FRAMERATE = 144;

ArrayList<Cloud> clouds;

float maxWeight;

//kinetic energy
final float KINETIC_THRESHOLD = .15;
float kineticEnergy = 1; //just so it gets called the first time

//single-call initialization function
void setup() {
  size(1400, 800);
  setupPlanets();
  graph = new Graph();
  graph.parse("data1.csv");
  clouds = new ArrayList<Cloud>();
  nebula_img = loadImage("nebula.jpg");
  m = new Minim(this);
  s1 = m.loadFile("interstellar_final.mp3", 1024);
}

void setupPlanets() {
  sparkle = loadImage("./planets/sparkle.png");
  planets = new ArrayList<PImage>(); 
  PImage img;
  for (int i = 0; i < NUM_PLANETS; i++) {
    String path = "./planets/p" + String.valueOf(i) + ".png";
    img = loadImage(path);
    planets.add(img);
  }
}

void changeFrameRate() {
  if (keyPressed && key == 107 && frames < MAX_FRAMERATE) {
    frames++;
  } else if (keyPressed && key == 106 && frames > MIN_FRAMERATE) {
    frames--;
  }
}

void applyReset() {
  for (Node node : graph.nodes) {
    node.x = random(0, width * 0.8);
    node.y = random(0, width * 0.8);
  }

  frames = 60;
}

// draw fx called @ 60fps (on std machines)
void draw() {
  frameRate(frames);
  if (nebula) {
    tint(150, 255);
    image(nebula_img, 0, 0);
    noTint();
  } else {
    background(255);
  }
  fill(color(red, green, blue));
  text("fps: "+ frames, 10, 15); //print fps
  if (updating) {
    text("energy: " + kineticEnergy, 10, 30);
  } else {
    text("energy: " + KINETIC_THRESHOLD, 10, 30);
  }

  if (kineticEnergy > KINETIC_THRESHOLD) {
    graph.applyCoulomb();
    graph.applyHooke();
    updating = true;
  } else {
    updating = false;
  }
  changeFrameRate();
  graph.applyMouseDrag();
  graph.update();
  if (nebula && rotateNebula)
  {
    pushMatrix();
    translate(width / 2, height / 2);
    rotate(rot);
    rot += ROTATION_DELTA;
  }
  graph.render();
  if (nebula && rotateNebula) {
    popMatrix();
  }
  drawToolTip();
  clearClouds();
  kineticEnergy = graph.getKineticEnergy();

  fill(color(red, green, blue));
  text("updating: " + updating, 10, 45);
}

void clearClouds() {

  Cloud cloud;
  while (clouds.size () > 0) {
    cloud = clouds.get(0);
    if (cloud.alpha <= 0) {
      clouds.remove(0);
    } else {
      break;
    }
  }
}

void mousePressed() {
  graph.startDragging();
}

void keyPressed() {

  if (key == ' ') {
    applyReset();
  }

  if (key == 's') {
    nebula = !nebula;
    if (nebula) {
      s1.play();
    } else {
      s1.pause();
    }

    if (rotateNebula) {
      rotateNebula = false;
      for (Node node : graph.nodes) {
        node.x += (width / 2);
        node.y += (height / 2);
      }
    }
  }

  if (key == 'r' && nebula) {
    rotateNebula = !rotateNebula;
    if (rotateNebula) {
      for (Node node : graph.nodes) {
        node.x -= (width / 2);
        node.y -= (height / 2);
      }
    } else {
      for (Node node : graph.nodes) {
        node.x += (width / 2);
        node.y += (height / 2);
      }
    }
  }
}

void drawToolTip() {
  for (Node node : graph.nodes) {
    if (node.dragging || node.mouseOver()) {
      if (nebula) {
        fill(240);
      } else {
        fill(0);
      }
      text("id: " + node.id, mouseX+1, mouseY-4.5);
      text("mass: " + node.weight, mouseX+1, mouseY-18.5);
    }
  }
}

void mouseReleased() {
  graph.stopDragging();
}

