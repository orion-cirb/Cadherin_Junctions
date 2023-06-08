// Prevent ImageJ from showing the processing steps
setBatchMode(true); 

// Show the user a dialog to select a directory of images
inputDirectory = getDirectory("Choose input directory");

// Get the list of files from the input directory
fileList = getFileList(inputDirectory+"junctions/");

// Create a directory to save results
outputDirectory = inputDirectory+"results/"
if (!File.isDirectory(outputDirectory)) {
	File.makeDirectory(outputDirectory);
}

// Generate a dialog box
Dialog.create("Select parameters");
Dialog.addNumber("Junctions classes nb", 2);
Dialog.addHelp("https://github.com/orion-cirb/Cadherin_Junctions");
Dialog.show();
nClasses = Dialog.getNumber();

// Create xls file to save results
file = File.open(outputDirectory+"results.xls");
header = "Image name\tNb nuclei\tBackground area\tBackground %\t";
for (i = 1; i <= nClasses; i++) {
	header += "Class "+i+" area\tClass "+i+" %\tClass "+i+" % (w/o bg)\t";
}
header += "Junction >50%\tJunction >50% (w/o bg)\n";
print(file, header);

for (i = 0; i < fileList.length; i++) {
	open(inputDirectory + "nuclei_seg/"+fileList[i]);
	setThreshold(255, 255);
	run("Analyze Particles...", "size=50-Infinity show=Nothing clear");
	nbNuclei = nResults;
	
	open(inputDirectory + "junctions_seg/" + fileList[i]);
	run("glasbey on dark");
	run("Median...", "radius=5");
	rename("overlay");
	
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
	imgSize = getValue("image.size");
	bgPerc = bgArea / imgSize * 100;
	classesPerc = newArray(nClasses-1);
	for (c = 0; c < nClasses; c++) {
		classesPerc[c] = classesArea[c] / imgSize * 100;
	}
	
	junction = "";
	for (c = 0; c < nClasses; c++) {
		if(classesPerc[c] >= 50) junction = "Class " + (c+1);
	}
	
	// Background not taken into account
	imgSizeNoBg = imgSize - bgArea;
	classesPercNoBg = newArray(nClasses-1);
	for (c = 0; c < nClasses; c++) {
		classesPercNoBg[c] = classesArea[c] / imgSizeNoBg * 100;
	}
	
	junctionNoBg = "";
	for (c = 0; c < nClasses; c++) {
		if(classesPercNoBg[c] >= 50) junctionNoBg = "Class " + (c+1);
	}
	
	result = fileList[i]+"\t"+nbNuclei+"\t"+bgArea+"\t"+bgPerc;
	for (c = 0; c < nClasses; c++) {
		result += "\t"+classesArea[c]+"\t"+classesPerc[c]+"\t"+classesPercNoBg[c];
	}
	result += "\t"+junction+"\t"+junctionNoBg+"\n";
	print(file, result);
	
	open(inputDirectory + "junctions/" + fileList[i]);
	run("Add Image...", "image=[overlay] x=0 y=0 opacity=15");
	saveAs("Tiff", outputDirectory + fileList[i]);
	close("*");
}


// Disable batch mode
setBatchMode(false);
