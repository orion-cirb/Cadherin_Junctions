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
print(file, "Image name\tNb nuclei\t64x64pix² ROI ID\tThin area\tFinger area\tReticular area\tBackground area\tThin %\tFinger %\tReticular %\tBackground %\tJunction >50%\n");
	
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
			thinPerc = thinArea / cellSize * 100;
			setThreshold(2, 2); // finger
			List.setMeasurements("limit");
			fingerArea = List.getValue("Area");
			fingerPerc = fingerArea / cellSize * 100;
			setThreshold(3, 3); // reticular
			List.setMeasurements("limit");
			reticularArea = List.getValue("Area");
			reticularPerc = reticularArea / cellSize * 100;
			setThreshold(4, 4); // background
			List.setMeasurements("limit");
			bgArea = List.getValue("Area");
			bgPerc = bgArea / cellSize * 100;
			
			junction = "";
			if(thinPerc >= 50) junction = "Thin";
			else if(fingerPerc >= 50) junction = "Finger";
			else if(reticularPerc >= 50) junction = "Reticular";
			print(file, replace(fileList[i], "-EGFP", "")+"\t"+nbNuclei+"\t"+roiID+"\t"+thinArea+"\t"+fingerArea+"\t"+reticularArea+"\t"+bgArea+"\t"+thinPerc+"\t"+fingerPerc+"\t"+reticularPerc+"\t"+bgPerc+"\t"+junction+"\n");
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
