// Prevent ImageJ from showing the processing steps
setBatchMode(true); 

// Show the user a dialog to select a directory of images
inputDirectory = getDirectory("Choose input directory");
// Create directories to save results
File.makeDirectory(inputDirectory+"nuclei/");
File.makeDirectory(inputDirectory+"nuclei_seg/");
File.makeDirectory(inputDirectory+"junctions/");
File.makeDirectory(inputDirectory+"junctions_seg/");
	
// Get the list of files from the input directory
fileList = getFileList(inputDirectory+"images/");
for (i = 0; i < fileList.length; i++) {
	open(inputDirectory+"images/"+fileList[i]);
	run("Split Channels");
	selectWindow("C1-"+fileList[i]);
	run("Z Project...", "projection=[Sum Slices]");
	saveAs("Tiff", inputDirectory+"nuclei/"+fileList[i].replace(".tif", "-DAPI.tif"));
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=10");
	run("Watershed");
	run("Invert LUT");
	saveAs("Tiff", inputDirectory+"nuclei_seg/"+fileList[i].replace(".tif", "-DAPI.tif"));
	close();
	close();
	selectWindow("C2-"+fileList[i]);
	run("Find focused slices", "select=80 variance=0.000 edge select_only");
	run("Z Project...", "projection=[Max Intensity]");
	run("Grays");
	saveAs("Tiff", inputDirectory+"junctions/"+fileList[i].replace(".tif", "-EGFP.tif"));
	close("*");
}

// Disable batch mode
setBatchMode(false);