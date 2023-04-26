run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1.0000000");
run("Grid...", "grid=Lines area=4096 color=White center");

roiID = 1;
for (j = 0; j < 32; j++) {
		for (k = 0; k < 32; k++) {
			setForegroundColor(255, 255, 255);
			setFont("SansSerif", 15, " antialiased");
			setColor("white");
			drawString(roiID, k*64+2, j*64+20);
			roiID++;
		}
}
			
			