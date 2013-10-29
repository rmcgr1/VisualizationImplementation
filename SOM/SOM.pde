int height = 500;
int width = 500;
int grid_height = 20;
int grid_width = 20;
int grid_pix_height = height / grid_height;
int grid_pix_width = width / grid_width;

int iterations = 500;
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

  frameRate(5);

  init_nodes();
  //init_color_samples();
  init_cancer_samples();
  init_map();
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


  //linear decreasing radius function
  radius = radius - .2;
  //println(radius);


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
        
        //println("sample " + s_val[0]);
        //println("node " + n_val[0]);

        float learn_rate = learning_const * exp(-float(t)/float(iterations));
        float theta = exp((-1 * pow(dist, 2))/(2*pow(radius, 2)*t));

        for (int i = 0; i < n_val.length; i++) {
          n_val[i] =  int(n_val[i] + learn_rate * theta * (s_val[i] - n_val[i]));
        }

        //println("learn_rate " + learn_rate);
        //println("theta " + theta);
        //println("new node " + n_val[0]);

        node.setValues(n_val);
      }
    }
  }



  //println("STEP");  
  //noLoop();
  t = t + 1;
  if (t >= iterations) {
    println("DONE");
    noLoop();
  }

  //Make video
  ///saveFrame("vid-####.jpg");
}


//algorithm steps
void init_cancer_samples() {
  Table table;
  table = loadTable("../data/usacancer_Ob.csv", "header");

  println("Label   brcamort   unemploy   pctpoor");
  int count = 0;
  for (TableRow row : table.rows()) {
    String label = row.getString("STATE_NAME");
    int label2 = row.getInt("KEY");
    float val1 = row.getFloat("rate_brcamort9397");
    float val2 = row.getFloat("unemploy");
    float val3 = row.getFloat("pctpoor");
    count = count + 1;

    val1 = scale_to_rgb(val1);
    val2 = scale_to_rgb(val2);
    val3 = scale_to_rgb(val3);
    label = label + "_" + label2;

    println(label + " " + val1 + " " + val2 + " " + val3); 

    samples.add(new Sample(label, new int[] {
      int(val1), int(val2), int(val3)
    }
    ));

    if (count == 10) {
      break;
    }
  }
}



void init_color_samples() {
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
  samples.add(new Sample("yellow", new int[] {
    255, 255, 0
  }
  ));
  samples.add(new Sample("white", new int[] {
    255, 255, 255
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
  
  //Mark where the best match is
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

 
float scale_to_rgb(float val) {
//transform values 0-100 to 0-255
  return val / 100 * 255;
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

