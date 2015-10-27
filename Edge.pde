public class Edge {
  public Node n1;
  public Node n2;
  public float idealLength;

  Edge(Node n1, Node n2, float idealLength) {
    this.n1 = n1;
    this.n2 = n2;
    this.idealLength = idealLength + n1.r + n2.r;
  }

  public void render() {
    if (!nebula) {
      fill(0);
      stroke(red, green, blue);
      strokeWeight(2);
      line(n1.x, n1.y, n2.x, n2.y);
    }
  }
}

