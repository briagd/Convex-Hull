class Particles {
  //array of PVector representing the coordinates of the set of points
  PVector [] points;
  //Array that will be used to store the original index of the point in points array
  //and angle between first vector (the one withe lowest y-values) in points and corresponding
  //point
  float [][] angles;
  //number of particles in the system
  int numParticles;

  //List that will store the points in the convex hull. A list is used rather than array
  //as points will be added and removed during the search
  ArrayList<PVector> convexHull;

  //time, a variable to control the motion of the points
  float t;

  //Constructor takes 3 arguments:
  //numP: number of particles in the system
  //w,h represent the horizontal and vertical range over which the points will be distributed randomly
  Particles(int numP, int w, int h) {
    numParticles = numP;
    points = new PVector[numParticles]; //initialize the array
    //assign random positions for the points over the range provided
    for (int i=0; i<numParticles; i++) {
      points[i]= new PVector( random(-w*0.7, w*0.7), random(-h*0.7, h*0.7));
    }

    angles = new float[numParticles][2];
    convexHull = new ArrayList<PVector>();
    t = 0;
  }

  //Put point with the lowest y-coordinate at the begining of points array
  void minYFirst() {
    float minY = 1.0e9;
    int idxMinY = 0;
    //finds the minimum y coordinate and index of corresponding point in points array
    for (int i=0; i<numParticles; i++) {
      if (points[i].y<minY) {
        minY = points[i].y;
        idxMinY = i;
      }
    }
    //swap point of minimum y-coordinate and first point in array(index 0)
    PVector temp = new PVector(points[0].x, points[0].y);
    points[0].x = points[idxMinY].x;
    points[0].y = points[idxMinY].y;
    points[idxMinY].x = temp.x;
    points[idxMinY].y = temp.y;
  }


  //creates an array (idx, tan(polar angle)) for each vector in an array of vector
  //tan(angle) will be faster than to calculate the angles and equivalent results are obtained
  void makeAngleArray() {
    for (int i=0; i<numParticles; i++) {
      angles[i][0] = i;      
      //prevents division by zero
      if (points[i].y-points[0].y ==0) {
        angles[i][1] = -(points[i].x-points[0].x)/(0.000001);
      } else {
        angles[i][1] = -(points[i].x-points[0].x)/( points[i].y-points[0].y);
      }
    }
  }



  //quicksort algorithm from https://en.wikipedia.org/wiki/Quicksort
  void quicksort(int lo, int hi) {
    if (lo<hi) {
      int p = partition(lo, hi);
      quicksort(lo, p-1);
      quicksort(p+1, hi);
    }
  }

  int partition(int lo, int hi) {
    float pivot = angles[hi][1];
    int i = lo;
    for (int j = lo; j<hi; j++) {
      if (angles[j][1] < pivot) {
        //swap angles[j] and angles[i]
        float tempAngle = angles[j][1];
        float tempIdx = angles[j][0];
        angles[j][0] = angles[i][0];
        angles[j][1] = angles[i][1];
        angles[i][0] = tempIdx;
        angles[i][1] = tempAngle;
        i = i+1;
      }
    } 
    //swap angles[i] and angles[hi]
    float tempAngle = angles[i][1];
    float tempIdx = angles[i][0];
    angles[i][0] = angles[hi][0];
    angles[i][1] = angles[hi][1];
    angles[hi][0] = tempIdx;
    angles[hi][1] = tempAngle;
    return i;
  }


  //rearrange points according to position in angle array
  void rearrangepoints() {
    PVector [] temppoints = new PVector[numParticles];
    for (int i=0; i<numParticles; i++) {
      temppoints[i] = new PVector(points[int(angles[i][0])].x, points[int(angles[i][0])].y);
    }
    arrayCopy(temppoints, points);
  }

  //Graham scan algorithm 
  //from https://en.wikipedia.org/wiki/Graham_scan
  // Three points are a counter-clockwise turn if ccw > 0, clockwise if
  // ccw < 0, and collinear if ccw = 0 because ccw is a determinant that
  // gives twice the signed  area of the triangle formed by p1, p2 and p3.
  float ccw(PVector p1, PVector p2, PVector p3) {
    return (p2.x-p1.x)*(p3.y-p1.y)-(p2.y-p1.y)*(p3.x-p1.x);
  }




  void makeConvexHull() {
    //swap points[0] with the point with the lowest y-coordinate
    minYFirst();
    //make array of angles between points[0] and other points
    makeAngleArray();
    //sort points by polar angle with points[0]
    quicksort(1, numParticles-1);
    //rearrange points according to the angles array
    rearrangepoints();
    //create an empty List where the points on the convex Hull will be stored
    convexHull = new ArrayList<PVector>();
    convexHull.add(points[0]);
    convexHull.add(points[1]);
    convexHull.add(points[2]);
    for (int i=3; i<numParticles; i++) {
      while (convexHull.size()>1 && ccw( convexHull.get(convexHull.size()-2), 
        convexHull.get(convexHull.size()-1), points[i] )<=0) {
        convexHull.remove(convexHull.size()-1);
      }
      convexHull.add(points[i]);
    }
  }
  
  //draw the points
  void drawPoints(float r) {
    for (int i =0; i<numParticles; i++) {
      fill(255);
      stroke(255);
      ellipse(points[i].x, points[i].y, r, r);
    }
  }
  
  //draws the convex Hull polygon 
  void drawConvexHull() {
    makeConvexHull();
    stroke(255);
    noFill();
    beginShape();
    for (int i=0; i < convexHull.size(); i++) {
      vertex(  convexHull.get(i).x,convexHull.get(i).y);
  }
      endShape(CLOSE);
  }
  
  //makes the points move around a bit to check that algorithm updates correctly
  void wiggle(float amount, float speed) {
    for (int i=0; i<numParticles; i++) {
      points[i].x += amount*(noise(i*10+speed*t)-0.5);
      points[i].y += amount*(noise(30+i*50+speed*t)-0.5);

    }
    t+=1;
  }
}
