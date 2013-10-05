int height = 500;
int width = 500;
int grid_height = 20;
int grid_width = 20;
int grid_pix_height = height / grid_height;
int grid_pix_width = width / grid_width;

ArrayList<Node> nodes = new ArrayList<Node>();

boolean debug = true;

void setup() {
  size(height, width);
  smooth();

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
}


//algorithm steps
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

  //init nodes
  for (int x = 0; x < grid_width; x++) {
    for (int y = 0; y < grid_height; y++) {
      int[] c = {int(random(255)), int(random(255)), int(random(255))};
      nodes.add(new Node(x, y, c)); 
      if (debug) {
        fill_square(x, y, c);
      }
    }
  }
}

//helper Functions
void fill_square(int grid_x, int grid_y, int[] c) {
  fill(c[0], c[1], c[2]);
  rect(grid_x * grid_width, grid_y * grid_height, grid_width, grid_height);
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

  int getx() {
    return x;
  }

  int gety() {
    return y;
  }
}

