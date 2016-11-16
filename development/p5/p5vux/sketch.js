// Visually UXposed
// based on tutorial of Daniel Shiffman
// http://www.learningprocessing.com

// Example 1-1: stroke and fill

  var table;
  var i;
  var j;
  var cellValue;
  var label;
  var test; 

  function preload() {
    matrix = loadTable("dataLayer2matrix.csv","csv")
    labels = loadTable("dataLayer2labels.csv","csv")
    test = matrix
  }
  
  function setup() {
    createCanvas(8000, 8000)
    noStroke()
    fill(0,0,255,10)
 
   angleMode(DEGREES)
   background(255,255,255)
   matrixStartX = 400
   matrixStartY = 450
   var matrixRows = matrix.getRows()
   var matrixSize = matrixRows.length

   // Experiment with grid
   fill(75, 75, 75, 50)
   for (r = 0; r <= matrixSize; r++) {
   rect(matrixStartX , matrixStartY + r * 20 - 1 , 20 * matrixSize, 1)
   rect(matrixStartX + r * 20 - 1 , matrixStartY, 1, 20 * matrixSize)
   }
   
   // Draw matrix
   for (var mr = 0; mr < matrixSize; mr++) {
       for (var mc = 0; mc < matrixSize; mc++) {
         cellValue = matrixRows[mr].getNum(mc)
         fill(49,130,189,cellValue*10)
         rect(mc * 20 + matrixStartX, mr * 20 + matrixStartY, 19 ,19)
       }
   }
   
   // Labels - horizontal
   fill(75, 75, 75, 255)
   labelsRow = labels.getRows()
   for (mc = 0; mc < matrixSize; mc++) {
       label = labelsRow[0].getString(mc)
       text(label, 10, mc*20+matrixStartY + 15)
   }
   
   // Labels - vertical
   push()
   translate(matrixStartX + 15, matrixStartY - 15)
   rotate(-90)
   for (mc = 0; mc < matrixSize; mc++) {
       label = labelsRow[0].getString(mc)
       text(label, 0, mc*20)
   }
   pop()
   
   // Title
   textSize(24)
   fill(50, 50, 50, 255)
   text("Visually UXposed - Matrix design (v 0.1 prototype)", 10, 40)
   
 }
 
    /*
    table = loadTable("flights.csv","csv","header")
   
   var rows = table.getRows()
   for (var r = 0; r < rows.length; r++) {
     var from_long = rows[r].getNum("from_long")
     var from_lat = rows[r].getNum("from_lat")
     var from_country = rows[r].getString("from_country")
     var to_country = rows[r].getString("to_country")
     var distance = rows[r].getNum("distance")
 
     var x = map(from_long,-180,180,0,width)
     var y = map(from_lat,-90,90,height,0)
     if ( from_country == to_country ) {
       fill(255,0,0,10)
     } else {
       fill(0,0,255,10)
     }
     var radius = map(distance,1,15406,3,15)
     ellipse(x,y,radius,radius)
   }
   */

 