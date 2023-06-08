// Prevent ImageJ from showing the processing steps
setBatchMode(true); 

// Show the user a dialog to select a directory of images
inputDirectory = getDirectory("Choose input directory");

// Get the list of files from the input directory
fileList = getFileList(inputDirectory+"junctions/");

// Create a directory to save results
outputDirectory = inputDirectory+"results_grid/"
if (!File.isDirectory(outputDirectory)) {
	File.makeDirectory(outputDirectory);
}

// Generate a dialog box
Dialog.create("Select junctions parameters");
Dialog.addNumber("Classes nb", 2);
Dialog.addHelp("https://github.com/orion-cirb/Cadherin_Junctions");
Dialog.show();
nClasses = Dialog.getNumber();

// Create xls file to save results
file = File.open(outputDirectory+"results_grid.xls");
header = "Image name\tNb nuclei\t64x64pix² ROI ID\tBackground area\tBackground %\t";
for (i = 1; i <= nClasses; i++) {
	header += "Class "+i+" area\tClass "+i+" %\tClass "+i+" % (w/o bg)\t";
}
header += "Junction >50%\tJunction >50% (w/o bg)\n";
print(file, header);


for (i = 0; i < fileList.length; i++) {
	open(inputDirectory + "nuclei_seg/" + fileList[i]);
	setThreshold(255, 255);
	run("Analyze Particles...", "size=50-Infinity show=Nothing clear");
	nbNuclei = nResults;
	
	open(inputDirectory + "junctions_seg/" + fileList[i]);
	run("glasbey on dark");
	run("Median...", "radius=5");
	rename("overlay");
	
	roiID = 1;
	cellSize = 64*64;
	for (j = 0; j < 32; j++) {
		for (k = 0; k < 32; k++) {
			run("Specify...", "width=64 height=64 x="+k*64+" y="+j*64);
			setThreshold(nClasses+1, nClasses+1); // background
			List.setMeasurements("limit");
			bgArea = List.getValue("Area");
			classesArea = newArray(nClasses-1);
			for (c = 0; c < nClasses; c++) {
				setThreshold(c+1, c+1); // class i+1
				List.setMeasurements("limit");
				classesArea[c] = List.getValue("Area");
			}		
			
			// Background taken into account
			bgPerc = bgArea / cellSize * 100;
			classesPerc = newArray(nClasses-1);
			for (c = 0; c < nClasses; c++) {
				classesPerc[c] = classesArea[c] / cellSize * 100;
			}
			
			junction = "";
			for (c = 0; c < nClasses; c++) {
				if(classesPerc[c] >= 50) junction = "Class " + (c+1);
			}

			// Background not taken into account
			cellSizeNoBg = cellSize - bgArea;
			classesPercNoBg = newArray(nClasses-1);
			for (c = 0; c < nClasses; c++) {
				classesPercNoBg[c] = classesArea[c] / cellSizeNoBg * 100;
			}
			
			junctionNoBg = "";
			for (c = 0; c < nClasses; c++) {
				if(classesPercNoBg[c] >= 50) junctionNoBg = "Class " + (c+1);
			}
	
			result = fileList[i]+"\t"+nbNuclei+"\t"+roiID+"\t"+bgArea+"\t"+bgPerc;
			for (c = 0; c < nClasses; c++) {
				result += "\t"+classesArea[c]+"\t"+classesPerc[c]+"\t"+classesPercNoBg[c];
			}
			result += "\t"+junction+"\t"+junctionNoBg+"\n";
			print(file, result);
			
			roiID++;
		}
	}
	
	open(inputDirectory + "junctions/" + fileList[i]);
	run("Add Image...", "image=[overlay] x=0 y=0 opacity=15");
	saveAs("Tiff", outputDirectory + fileList[i]);
	close("*");
}

// Disable batch mode
setBatchMode(false);
