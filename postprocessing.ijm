// Prevent ImageJ from showing the processing steps
setBatchMode(true); 

// Show the user a dialog to select a directory of images
inputDirectory = getDirectory("Choose input directory");
// Create a directory to save results
outputDirectory = inputDirectory+"results/"
if (!File.isDirectory(outputDirectory)) {
	File.makeDirectory(outputDirectory);
}

// Create xls file to save results
file = File.open(outputDirectory+"results.xls");
print(file, "Image name\tNb nuclei\tThin area\tFinger area\tReticular area\tBackground area\tThin %\tFinger %\tReticular %\tBackground %\tJunction >50%\tThin % (w/o bg)\tFinger % (w/o bg)\tReticular % (w/o bg)\tJunction >50% (w/o bg)\n");
	
// Get the list of files from the input directory
fileList = getFileList(inputDirectory+"junctions/");
for (i = 0; i < fileList.length; i++) {
	open(inputDirectory + "nuclei_seg/" + replace(fileList[i], "EGFP", "DAPI"));
	setThreshold(255, 255);
	run("Analyze Particles...", "size=50-Infinity show=Nothing clear");
	nbNuclei = nResults;
	
	open(inputDirectory + "junctions_seg/" + fileList[i]);
	run("glasbey on dark");
	run("Median...", "radius=5");
	
	setThreshold(1, 1); // thin
	List.setMeasurements("limit");
	thinArea = List.getValue("Area");
	setThreshold(2, 2); // finger
	List.setMeasurements("limit");
	fingerArea = List.getValue("Area");
	setThreshold(3, 3); // reticular
	List.setMeasurements("limit");
	reticularArea = List.getValue("Area");
	setThreshold(4, 4); // background
	List.setMeasurements("limit");
	bgArea = List.getValue("Area");
	
	// Background taken into account
	imgSize = getValue("image.size");
	thinPerc = thinArea / imgSize * 100;
	fingerPerc = fingerArea / imgSize * 100;
	reticularPerc = reticularArea / imgSize * 100;
	bgPerc = bgArea / imgSize * 100;
	
	junction = "";
	if(thinPerc >= 50) junction = "Thin";
	else if(fingerPerc >= 50) junction = "Finger";
	else if(reticularPerc >= 50) junction = "Reticular";
	
	// Background not taken into account
	imgSizeNoBg = imgSize - bgArea;
	thinPercNoBg = thinArea / imgSizeNoBg * 100;
	fingerPercNoBg = fingerArea / imgSizeNoBg * 100;
	reticularPercNoBg = reticularArea / imgSizeNoBg * 100;
	
	junctionNoBg = "";
	if(thinPercNoBg >= 50) junctionNoBg = "Thin";
	else if(fingerPercNoBg >= 50) junctionNoBg = "Finger";
	else if(reticularPercNoBg >= 50) junctionNoBg = "Reticular";
	
	print(file, replace(fileList[i], "-EGFP", "")+"\t"+nbNuclei+"\t"+thinArea+"\t"+fingerArea+"\t"+reticularArea+"\t"+bgArea+"\t"+thinPerc+"\t"+fingerPerc+"\t"+reticularPerc+"\t"+bgPerc+"\t"+junction+"\t"+thinPercNoBg+"\t"+fingerPercNoBg+"\t"+reticularPercNoBg+"\t"+junctionNoBg+"\n");
	
	open(inputDirectory + "junctions/" + fileList[i]);
	run("Add Image...", "image=["+ fileList[i] +"] x=0 y=0 opacity=15");
	saveAs("Tiff", outputDirectory + fileList[i]);
	close("*");
}

// Disable batch mode
setBatchMode(false);
