// Visually UXposed
// based on tutorial of Daniel Shiffman
// http://www.learningprocessing.com

// Example 1-1: stroke and fill

  var table;
  var i, j;
  var cellValue;
  var label;
  var test;
  var matrixRows;
  var matrixSize;
  var x, y, z;

  var positionTranslator = []

  var contrastSlider;
  var filterSlider;

  matrixStartX = 190
  matrixStartY = 230

  cellSize = 10;
  labelShift = 10 + 0
  columnShiftSize = 10

  function preload() {
    matrix = loadTable("dataLayer2displayMatrix.csv","csv")
    labels = loadTable("dataLayer2labels.csv","csv")
    tasksLabelsTable = loadTable("dataLayer2tasksLabels.csv", "csv")
    columnShiftTable = loadTable("dataLayer2columnBreaks.csv","csv")
    columnColorIndexTable = loadTable("dataLayer2columnColorIndex.csv","csv")
  }

  function setup() {
    createCanvas(3000, 3000) // There is a maximum, 8000?
    noStroke()
    //noLoop()
    fill(0,0,255,10)
    angleMode(DEGREES)
    matrixRows = matrix.getRows()
    matrixSize = matrixRows.length

    colummnShifts = columnShiftTable.getRows()
    columnColorIndex = columnColorIndexTable.getRows()

    columnColorIndexArray = []
    colummnShiftsArray = []

    for (i = 0; i < matrixSize; i++) {
      columnColorIndexArray.push(columnColorIndex[0].getNum(i))
      colummnShiftsArray.push(colummnShifts[0].getNum(i))
    }

    // setup for tasks labels
    tasksLabelsRows = tasksLabelsTable.getRows()
    nTasks          = tasksLabelsRows.length
    tasksLabelsText = []
    tasksPosition  = []
    for (i = 0; i < nTasks; i++) {
      tasksPosition.push(tasksLabelsRows[i].getNum(0))
      tasksLabelsText.push(tasksLabelsRows[i].getString(1))
    }

    // Setup the sliders
    contrastSlider = createSlider(1, 10, 2)
    contrastSlider.position(10, 100)
    contrastSlider.style('width', '150px')
    filterSlider = createSlider(0, 255, 0)
    filterSlider.position(10, 150)
    filterSlider.style('width', '150px')

  }

 function draw() {

   background(240,240,240)
   //background(255,255,255)
   //background(200,200,200)
   //background(240, 220, 220)
   //background(255,255,191) // yellow

   // draw Title
   textSize(24)
   fill(50, 50, 50, 255)
   text("Visually UXposed - Matrix design (v 0.4)", 10, 40)

   textSize(16)
   text("Contrast", 10, 90)
   text("Filter", 10, 140)


   // DRAW LABELS
   textSize(10)
   textStyle(NORMAL)

   // draw Labels - horizontal
   fill(75, 75, 75, 255)
   labelsRow = labels.getRows()
   for (mc = 0; mc < matrixSize - 1; mc++) {
       label = labelsRow[0].getString(mc)
       x = 10
       y = mc * cellSize + matrixStartY + labelShift + colummnShifts[0].getNum(mc) * columnShiftSize
       if (columnColorIndexArray[mc] == 0) {
         fill(75, 75, 75, 255)
       } else {
         fill(250, 100, 100)
       }
       text(label, x, y)
   }
   textStyle(BOLD)
   fill(75, 0, 75, 255)
   for (i = 0; i < nTasks; i++) {
     y = matrixStartY + tasksPosition[i] * cellSize + 2 * cellSize + i * columnShiftSize
     text(tasksLabelsText[i], 5, y)
   }
   textStyle(NORMAL)

   // draw Labels - vertical
   push()
   fill(75, 75, 75, 255)
   translate(matrixStartX + labelShift, matrixStartY - labelShift)
   rotate(-90)
   for (mc = 1; mc < matrixSize; mc++) {
       label = labelsRow[0].getString(mc)
       y = mc*cellSize + colummnShifts[0].getNum(mc) * columnShiftSize
       if (columnColorIndexArray[mc] == 0) {
         fill(75, 75, 75, 255)
       } else {
         fill(250, 100, 100)
       }
       text(label, 5, y)
   }
   textStyle(BOLD)
   //fill(75, 0, 75, 255)
   fill(0)
   for (i = 0; i < nTasks; i++) {
     y = tasksPosition[i] * cellSize + 1 * cellSize + i * columnShiftSize
     text(tasksLabelsText[i], 0, y)
   }
   pop()


   // draw matrix
   for (var mr = 0; mr < matrixSize - 1; mr++) {
       for (var mc = 1; mc < matrixSize; mc++) {
         matrixValue = matrixRows[mr].getNum(mc)
         if (matrixValue < filterSlider.value()) {
           filteredValue = 0
         } else {
           filteredValue = matrixValue
         }
         cellValue = filteredValue * contrastSlider.value()
         x = mc * cellSize + matrixStartX + colummnShiftsArray[mc]  * columnShiftSize
         y = mr * cellSize + matrixStartY + colummnShiftsArray[mr]  * columnShiftSize
         fill(255,255,255)
         rect(x, y, cellSize-1 ,cellSize-1)
         if (cellValue == 0) {
           //fill(49,130,189,0)
           fill(255,255,255)
         } else {
           if (columnColorIndexArray[mc] == 0) {
             //fill(49, 130, 189, cellValue)
             //fill(35, 139, 59, cellValue) // green
             fill(33, 102, 172, cellValue)
           } else {
             fill(250, 80, 80, cellValue)
             //fill(203,59,44)
           }
         }
         rect(x, y, cellSize-1 ,cellSize-1)
       }
   }

   // Cell Labels

   if (mouseX > matrixStartX && mouseY > matrixStartY) {
       indexI = floor((mouseX - matrixStartX) / cellSize)
       indexJ = floor((mouseY - matrixStartY) / cellSize)
       posI = matrixStartX + indexI * cellSize + 10
       posJ = matrixStartY + indexJ * cellSize + 10
       labelValue = matrixRows[indexJ].getNum(indexI)
       fill(0,0,0)
       textSize(15)
       toolTipText = labelsRow[0].getString(indexJ) + "\n" + labelsRow[0].getString(indexI)
    text("(" + indexI + ", " + indexJ + ") " + "\n" + toolTipText + "\n" + " Frequency: "  + labelValue  , posI, posJ)
   }

   /*
      // draw grid
      fill(75, 75, 75, 50)
      for (r = 0; r < matrixSize; r++) {
        //z = r * cellSize - 1 + colummnShifts[0].getNum(r)  * columnShiftSize
        z = r * cellSize - 1 + colummnShiftsArray[r]  * columnShiftSize
      rect(matrixStartX , matrixStartY + z, cellSize * matrixSize + colummnShiftsArray[matrixSize-1] * columnShiftSize, 1)
      //rect(matrixStartX + z, matrixStartY, 1, cellSize * matrixSize + colummnShifts[0].getNum(matrixSize-1) * columnShiftSize)
      rect(matrixStartX + z, matrixStartY, 1, cellSize * matrixSize + colummnShiftsArray[matrixSize-1] * columnShiftSize)
      }
   */

 }
