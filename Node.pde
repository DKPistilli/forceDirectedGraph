import java.util.List;
import java.util.ArrayList;

public class Node {

  private static final float RADIUS_FACTOR = 60;
  private static final float BASE_RADIUS = 10;

  public float x;
  public float y;
  public float r;
  public color c;

  public float vx;
  public float vy;

  public int id;
  public float weight;

  public PImage planet;

  public boolean dragging;

  List<Force> forces;

  Node(int id, int weight) {
    this.id = id;
    this.weight = float(weight);

    x = random(0, (width*.8));
    y = random(0, (height*.8));
    c = createColor();
    vx = 0;
    vy = 0;
    this.dragging = false;

    r = BASE_RADIUS + (float)weight / (float)maxWeight * RADIUS_FACTOR;

    planet = planets.get(planetCounter);
    if (planetCounter > planets.size()) {
      planetCounter = 0;
    } else {
      planetCounter ++;
    }

    forces = new ArrayList<Force>();
  }

  private color createColor() {
    //return color(random(0, 255), random(0, 255), random(0, 255));
    return color(red, green, blue);
  }

  public void render() {
    if (!nebula) {
      if (dragging || mouseOver()) {

        fill(fill_red, fill_green, fill_blue);
      } else {
        fill(c);
      }
      //println("print circle with id " + id + " and (x,y) of (" + x + "," + y + ")"); 
      noStroke();
      ellipse(x, y, r, r);
    } else {
      float new_r = r * 2;
      image(planet, x - (new_r / 2), y - (new_r / 2), new_r, new_r);
    }
  }

  public boolean mouseOver() {
    float c = dist(mouseX, mouseY, x, y);
    if (c <= (r/2)+3) { //TODO: fix this hacky highlight
      return true;
    } else {
      return false;
    }
  }

  public void addForce(Force f) {
    forces.add(f);
  }

  public void clearForces() {
    forces.clear();
  }


  private float bound(float val) { //TODO: RETURNS NEGATIVE VALS LESS THAN EPSILON AS POSITIVE EPSILON
    if (abs(val) > 0+EPSILON) {
      return val;
    } else {
      if (val > 0) {
        return 0+EPSILON;
      } else {
        return 0-EPSILON;
      }
    }
  }

  public void applyForces() {

    Force friction = new Force();
    float magnitude = sqrt((vx * vx) + (vy * vy));

    if (magnitude > 0+EPSILON) {
      friction.x = (-1 * vx) / magnitude;
      friction.y = (-1 * vy) / magnitude;
      friction.magnitude = magnitude * DAMPENING_FACTOR;
    }

    addForce(friction);

    float xTotal = 0;
    float yTotal = 0;

    for (Force f : forces) {
      xTotal += (f.x * f.magnitude);
      yTotal += (f.y * f.magnitude);
    }

    float xAcceleration = (xTotal / weight);
    float yAcceleration = (yTotal / weight);

    vx += xAcceleration;
    vy += yAcceleration;
  }

  public void update() {

    if (weight > maxWeight) {
      maxWeight = weight;
    }

    x += vx;
    y += vy;
  }

  public float getKineticEnergy() {
    //println("energy = 0.5 * " + weight + " (" + vx + "^2 + " + vy + "^2)");
    return 0.5 * weight * sqrt((vx * vx) + (vy * vy));
  }

  private final float GROWTH_CONSTANT = 0.5;

  public void grow() {
    float currentWeight = weight;
    float newWeight = weight + GROWTH_CONSTANT;

    float currentRadius = r;
    float newRadius = currentRadius * (currentWeight / newWeight);

    r = newRadius;
    weight += GROWTH_CONSTANT;
  }

  public void shrink() {
    if (weight > 2) {
      float currentWeight = weight;
      float newWeight = weight - GROWTH_CONSTANT;

      float currentRadius = r;
      float newRadius = currentRadius * (currentWeight / newWeight);

      r = newRadius;
      weight -= GROWTH_CONSTANT;
    }
  }
}

