int height = 500;
int width = 500;
int grid_height = 20;
int grid_width = 20;
int grid_pix_height = height / grid_height;
int grid_pix_width = width / grid_width;

int iterations = 50;
int t = 1;

ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Sample> samples = new ArrayList<Sample>();

PFont f;

boolean debug = true;

float learning_const = 0.1;

//decreasing neighbor function
// sig(t) = sig0 * exp(-t/lambda)

float start_radius = grid_width;
float radius = grid_width;

void setup() {
  size(height, width);
  smooth();

  f = createFont("Helvetica", 11);
  textAlign(CENTER); 

  frameRate(2);

  init_nodes();
  init_samples();
  init_map();

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
  redraw_grid();
  float lambda = 0;


  //for the time being:
  radius = radius - .2;
  println(radius);


  //Need to randomize which sample is picked first?
  for ( Sample sample : samples) {
    Node winner = best_matching(sample);
    /*
      lambda = float(t)/log(start_radius);
     radius = start_radius * exp(float(-t)/lambda);
     println(radius);
     //OR:
     radius = exp(-6.6666666*sqrt(sqrt(pow(x,2) + pow(y,2))))
     //decrease this function lineraly?
     radius = radius * 1/iterations;
     */



    //find all that are in that radius
    for ( Node node : nodes) {
      float dist = sqrt(pow(node.getX()-winner.getX(), 2) + pow(node.getY()-winner.getY(), 2));
      //Converting from radius of pixels to boxes, what if the grid is not square? 
      if ((dist)  < radius) {
        //if (sample.getLabel() == "red") {

          //Marking techniques
          //fill(0);
          //textSize(18);
          //text("X", node.getX() * grid_pix_width, node.getY() * grid_pix_height);
          //Or:
          //fill_square(node.getX(), node.getY(), new int[]{0,0,0} );

          //Adjust values according to: W(t+1) = W(t) + theta(t)L(t)(V(t)-W(t))
          //Learning rate L(t)=L0*exp(-t/lambda) (exponential decay function)
          //influence of distance, theta = exp(-(dist)^2/2sig^2(t))

          int[] n_val = node.getValues();
          int[] s_val = sample.getValues();
          println("");      
          println("sample " + s_val[0]);
          println("node " + n_val[0]);

          float learn_rate = learning_const * exp(-float(t)/float(iterations));
          float theta = exp((-1 * pow(dist, 2))/(2*pow(radius, 2)*t));

          for (int i = 0; i < n_val.length; i++) {
            n_val[i] =  int(n_val[i] + learn_rate * theta * (s_val[i] - n_val[i]));
          }

          println("learn_rate " + learn_rate);
          println("theta " + theta);
          println("new node " + n_val[0]);

          node.setValues(n_val);
        //}
      }
    }
  }




  //noLoop();
  t = t + 1;
  if (t >= iterations) {
    println("DONE");
    noLoop();
  }

  println("STEP");
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

  for (Node n : nodes) {
    int[] n_val = n.getValues();
    int[] s_val = sample.getValues();
    float dist =  sqrt(pow(n_val[0]-s_val[0], 2) + pow(n_val[1]-s_val[1], 2) + pow(n_val[2]-s_val[2], 2));

    if (dist < closest_val) {
      closest_val = dist;
      closest = n;
    }
  }
  //println("BM " + sample.getLabel() + " " + closest.getX() + ", " + closest.getY()); 

  fill(0);
  textSize(18);
  text(sample.getLabel(), closest.getX() * grid_pix_width + grid_pix_width/2, closest.getY() * grid_pix_height + grid_pix_width/2);

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

  void setValues(int[] values) {
    this.values = values;
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

