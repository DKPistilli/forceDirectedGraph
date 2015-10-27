import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

public class Graph {
  public List<Edge> edges;
  public List<Node> nodes;
  public HashMap<Integer, Node> nodeMap;

  Graph() {
    edges = new ArrayList<Edge>();
    nodes = new ArrayList<Node>();
    nodeMap = new HashMap<Integer, Node>();
  }

  public void render() {
    
    for (Cloud cloud : clouds) {
      cloud.render();
    }

    for (Edge curEdge : edges) {
      curEdge.render();
    }

    for (Node curNode : nodes) {
      curNode.render();
    }
  }


  void parse(String path) {

    String[] fileLines = loadStrings(path); //input all lines from file
    String[] currLine; 
    int i = 0; 

    int numNodes = int(fileLines[i]); 
    color c = color(10, 30, 177); //node color

    // find the maximum mass so all other nodes can be initialized proportionally
    for (i = 1; i <= numNodes; i++) {
      currLine = split(fileLines[i], ","); 
      if (int(currLine[1]) > maxWeight) {
        maxWeight = int(currLine[1]);
      }
    }
    println("maxWeight: " + maxWeight); 


    // push all nodes on to the nodelist w/ a random init x & y.
    for (i = 1; i <= numNodes; i++) {
      currLine = split(fileLines[i], ","); 
      Node newNode = new Node(int(currLine[0]), int(currLine[1])); 
      nodes.add(newNode); 
      nodeMap.put(newNode.id, newNode);
    }


    int numEdges = int(fileLines[numNodes+1]); 

    //push all edges onto edge list
    for (i = numNodes+2; i < numEdges+ (numNodes+2); i++) {
      currLine = split(fileLines[i], ","); 
      Edge newEdge = new Edge(nodeMap.get(int(currLine[0])), nodeMap.get(int(currLine[1])), float(currLine[2])); 
      edges.add(newEdge); 
      //println("Creating edge between " + newEdge.n1.id + " and " + newEdge.n2.id + " with ideal length " + newEdge.idealLength);
    }
  }

  public void applyCoulomb() {
    int len = nodes.size();
    Node n1;
    Node n2;
    for (int i = 0; i < len; i++) {
      for (int j = i+1; j < len; j++) {

        n1 = nodes.get(i);
        n2 = nodes.get(j);
        makeCoulomb(n1, n2);
      }
    }
  }

  private void makeCoulomb(Node n1, Node n2) {
    float xDiff = bound(n1.x - n2.x);
    float yDiff = bound(n1.y - n2.y);
    float magnitude = bound(sqrt((xDiff * xDiff) + (yDiff * yDiff)));

    float xPortion = bound(xDiff / magnitude); //TODO: shoudl we bound?
    float yPortion = bound(yDiff / magnitude); //TODO: should we bound?

    Force n1Coulomb = new Force();
    n1Coulomb.magnitude = COULOMB_K / magnitude;
    n1Coulomb.x = xPortion;
    n1Coulomb.y = yPortion;
    n1.addForce(n1Coulomb);

    Force n2Coulomb = new Force();
    n2Coulomb.magnitude = COULOMB_K / magnitude;
    n2Coulomb.x = -1 * xPortion;
    n2Coulomb.y = -1 * yPortion;
    n2.addForce(n2Coulomb);
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

  public void applyHooke() {
    Node n1;
    Node n2;
    float ideal;

    for (Edge edge : edges) {
      n1 = edge.n1;
      n2 = edge.n2;
      ideal = edge.idealLength;
      makeHooke(n1, n2, ideal);
    }
  }

  private void makeHooke(Node n1, Node n2, float idealLength) {
    float xDiff = bound(n1.x - n2.x);
    float yDiff = bound(n1.y - n2.y);
    // account for circle size when making edge force
    float distance = bound(sqrt((xDiff * xDiff) + (yDiff * yDiff))); 
    float delta = bound(distance - idealLength);

    float xPortion = bound(xDiff / distance); //TODO: should we bound?
    float yPortion = bound(yDiff / distance);

    Force n1Hooke = new Force();
    n1Hooke.magnitude = HOOKE_K * delta;
    n1Hooke.x = -1 * xPortion;
    n1Hooke.y = -1 * yPortion;
    n1.addForce(n1Hooke);

    Force n2Hooke = new Force();
    n2Hooke.magnitude = HOOKE_K * delta;
    n2Hooke.x = xPortion;
    n2Hooke.y = yPortion;
    n2.addForce(n2Hooke);
  }

  public void applyMouseDrag() {
    for (Node node : nodes) {
      if (node.dragging) {
        makeMouseDrag(node);
      }
    }
  }

  private void makeMouseDrag(Node node) {
    float xDiff = bound(node.x - mouseX);
    float yDiff = bound(node.y - mouseY);
    float distance = bound(sqrt((xDiff * xDiff) + (yDiff * yDiff)));
    
    float xPortion = xDiff / distance; //TODO: should we bound?
    float yPortion = yDiff / distance;

    Force mouseDrag = new Force();
    mouseDrag.magnitude = MOUSE_K * distance;
    mouseDrag.x = -1 * xPortion;
    mouseDrag.y = -1 * yPortion;
    node.addForce(mouseDrag);
  }

  public float getKineticEnergy() {
    float total = 0;
    for (Node node : nodes) {
      total += node.getKineticEnergy();
    }
    return total;
  }

  public void update() {

    for (Node node : nodes) {
      //make new cloud if dragging
      if (node.dragging) {
        clouds.add(new Cloud(node.x, node.y, (node.r * .75)));
      }
      
      node.applyForces();
      node.update();
      node.clearForces();
    }
    
    for (Cloud cloud : clouds) {
      cloud.update();
    }
  }
  
  public void applyWeightChange() {
    for (Node node : nodes) {
      if (node.dragging && (mousePressed) && (keyPressed) && (keyCode==CONTROL)) {
        node.grow();
      } else if (node.dragging && (mousePressed) && (keyPressed) && (keyCode==SHIFT)) {
        node.shrink();
      }
    }
  }

  public void startDragging() {
    for (Node node : nodes) {
      node.dragging = node.mouseOver();
    }
    
  }

  public void stopDragging() {
    for (Node node : nodes) {
      node.dragging = false;
    }
  }
}

