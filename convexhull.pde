//Implementation of the Graham scan algorithm to find the convex hull




Particles p;
int numParticles = 1000;

void setup() {
  size(600, 600);
  background(0);
  p=new Particles(numParticles,width/4,height/4);
}



void draw() {
  background(0);
  pushMatrix();
  translate(width/2, height/2);
  p.drawConvexHull();
  p.drawPoints(2);
  p.wiggle(5,0.01);
  popMatrix();
  
}

void mouseClicked(){
 saveFrame("convexHull-######.png"); 
}
