int height = 500;
int width = 500;
int grid_height = 20;
int grid_width = 20;
int grid_pix_height = height / grid_height;
int grid_pix_width = width / grid_width;
int iterations = 20;

ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Sample> samples = new ArrayList<Sample>();

PFont f;

boolean debug = true;

//decreasing neighbor function
// sig(t) = sig0 * exp(-t/lambda)
float start_radius = 8;
float radius = 0;

void setup() {
  size(height, width);
  smooth();

  f = createFont("Helvetica", 11);
  textAlign(CENTER); 

  frameRate(.5);

  init_nodes();
  init_samples();


  /*Table table;
   table = loadTable("filtered_data.csv", "header");
   
   int count = 0;
   for (TableRow row : table.rows()) {
   xs[0][count] = row.getInt("Asian");
   xs[1][count] = row.getInt("Black/African American");
   xs[2][count] = row.getInt("Hispanic/Latino");
   xs[3][count] = row.getInt("International");
   xs[4][count] = row.getInt("Native Hawaiian/Other Pacific Islander");
   xs[5][count] = row.getInt("Not Specified");
   xs[6][count] = row.getInt("Two or More");
   xs[7][count] = row.getInt("White");    
   count = count + 1;
   }
   */
}

/*
Algorithm:
 
 Initialize Map
 For t from 0 to 1
 
 Randomly select a sample
 Get best matching unit
 Scale neighbors
 Increase t a small amount
 
 End for
 
 */


void draw() {
  background(255);
  init_map();
  float lambda = 0;
  
  for (int t = 0; t < iterations; t++) {
    //Need to randomize which sample is picked first?
    for ( Sample sample : samples) {
      Node winner = best_matching(sample);
      /*
      lambda = float(t)/log(start_radius);
      radius = start_radius * exp(float(-t)/lambda);
      println(radius);
      */
    }
  } 


  println("DONE");
  noLoop();
}


//algorithm steps
void init_samples() {
  samples.add(new Sample("red", new int[] {
    255, 0, 0
  }
  )); 
  samples.add(new Sample("green", new int[] {
    0, 255, 0
  }
  ));
  samples.add(new Sample("blue", new int[] {
    0, 0, 255
  }
  ));
}

void init_map() {

  //draw grid
  for (int i = 0; i < width; i = i + grid_pix_width) {
    stroke(0);
    line(i, 0, i, height);
  }

  for (int i = 0; i < height; i = i + grid_pix_height) {
    stroke(0);
    line(0, i, width, i);
  }

  //draw nodes
  if (debug) {
    for (Node n : nodes) {
      fill_square(n.getX(), n.getY(), n.getValues() );
    }
  }
}

void init_nodes() {
  //init nodes
  for (int x = 0; x < grid_width; x++) {
    for (int y = 0; y < grid_height; y++) {
      int[] c = {
        int(random(255)), int(random(255)), int(random(255))
      };
      nodes.add(new Node(x, y, c));
    }
  }
}

Node best_matching(Sample sample) {
  //Randomize in case of tie?
  Node closest = nodes.get(1);
  float closest_val = 10000;

  println("BM " + sample.getLabel());

  for (Node n : nodes) {
    int[] n_val = n.getValues();
    int[] s_val = sample.getValues();
    float dist =  sqrt(pow(n_val[0]-s_val[0],2) + pow(n_val[1]-s_val[1],2) + pow(n_val[2]-s_val[2],2));
    
    if (dist < closest_val) {
      closest_val = dist;
      closest = n;
    }
  }
  println("BM " + sample.getLabel() + " " + closest.getX() + ", " + closest.getY()); 
  
  fill(0);
  textSize(18);
  text(sample.getLabel(), closest.getX() * grid_pix_width, closest.getY() * grid_pix_height);

  return closest;
}

//helper Functions
void fill_square(int grid_x, int grid_y, int[] c) {
  fill(c[0], c[1], c[2]);
  rect(grid_x * grid_pix_width, grid_y * grid_pix_height, grid_pix_width, grid_pix_height);
}

void redraw_grid() {
  for (Node n: nodes) {
    fill_square(n.getX(), n.getY(), n.getValues());
  }
}

//object classes
class Node {
  int x;
  int y;
  int[] values;

  Node(int x, int y, int[] values) {
    this.x = x;
    this.y = y;
    this.values = values;
  }   

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }

  int[] getValues() {
    return values;
  }
}

class Sample {
  int[] values;
  String label;

  Sample(String label, int[] values) {
    this.label = label;
    this.values = values;
  } 

  String getLabel() {
    return label;
  }

  int[] getValues() {
    return values;
  }
}

