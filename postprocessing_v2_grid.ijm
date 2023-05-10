// Prevent ImageJ from showing the processing steps
setBatchMode(true); 

// Show the user a dialog to select a directory of images
inputDirectory = getDirectory("Choose input directory");
// Create a directory to save results
outputDirectory = inputDirectory+"results_grid/"
if (!File.isDirectory(outputDirectory)) {
	File.makeDirectory(outputDirectory);
}

// Create xls file to save results
file = File.open(outputDirectory+"results_grid.xls");
print(file, "Image name\tNb nuclei\t64x64pix² ROI ID\tThin area\tFinger area\tReticular area\tFinger-reticular area\tBackground area\tThin %\tFinger %\tReticular %\tFinger-reticular %\tBackground %\tJunction >50%\tThin % (w/o bg)\tFinger % (w/o bg)\tReticular % (w/o bg)\tFinger-reticular % (w/o bg)\tJunction >50% (w/o bg)\n");
	
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
	roiID = 1;
	cellSize = 64*64;
	for (j = 0; j < 32; j++) {
		for (k = 0; k < 32; k++) {
			run("Specify...", "width=64 height=64 x="+k*64+" y="+j*64);
			setThreshold(1, 1); // thin
			List.setMeasurements("limit");
			thinArea = List.getValue("Area");
			setThreshold(2, 2); // finger
			List.setMeasurements("limit");
			fingerArea = List.getValue("Area");
			setThreshold(3, 3); // reticular
			List.setMeasurements("limit");
			reticularArea = List.getValue("Area");
			setThreshold(4, 4); // finger-reticular
			List.setMeasurements("limit");
			fingerReticularArea = List.getValue("Area");
			setThreshold(5, 5); // background
			List.setMeasurements("limit");
			bgArea = List.getValue("Area");
			
			// Background taken into account
			thinPerc = thinArea / cellSize * 100;
			fingerPerc = fingerArea / cellSize * 100;
			reticularPerc = reticularArea / cellSize * 100;
			fingerReticularPerc = fingerReticularArea / cellSize * 100;
			bgPerc = bgArea / cellSize * 100;
			
			junction = "";
			if(thinPerc >= 50) junction = "Thin";
			else if(fingerPerc >= 50) junction = "Finger";
			else if(reticularPerc >= 50) junction = "Reticular";
			else if(fingerReticularPerc >= 50) junction = "Finger-reticular";
			
			// Background not taken into account
			cellSizeNoBg = cellSize - bgArea;
			thinPercNoBg = thinArea / cellSizeNoBg * 100;
			fingerPercNoBg = fingerArea / cellSizeNoBg * 100;
			reticularPercNoBg = reticularArea / cellSizeNoBg * 100;
			fingerReticularPercNoBg = fingerReticularArea / cellSizeNoBg * 100;
			
			junctionNoBg = "";
			if(thinPercNoBg >= 50) junctionNoBg = "Thin";
			else if(fingerPercNoBg >= 50) junctionNoBg = "Finger";
			else if(reticularPercNoBg >= 50) junctionNoBg = "Reticular";
			else if(fingerReticularPercNoBg >= 50) junctionNoBg = "Finger-reticular";
	
			print(file, replace(fileList[i], "-EGFP", "")+"\t"+nbNuclei+"\t"+roiID+"\t"+thinArea+"\t"+fingerArea+"\t"+reticularArea+"\t"+fingerReticularArea+"\t"+bgArea+"\t"+thinPerc+"\t"+fingerPerc+"\t"+reticularPerc+"\t"+fingerReticularPerc+"\t"+bgPerc+"\t"+junction+"\t"+thinPercNoBg+"\t"+fingerPercNoBg+"\t"+reticularPercNoBg+"\t"+fingerReticularPercNoBg+"\t"+junctionNoBg+"\n");
			roiID++;
		}
	}
	
	open(inputDirectory + "junctions/" + fileList[i]);
	run("Add Image...", "image=["+ fileList[i] +"] x=0 y=0 opacity=15");
	saveAs("Tiff", outputDirectory + fileList[i]);
	close("*");
}

// Disable batch mode
setBatchMode(false);
