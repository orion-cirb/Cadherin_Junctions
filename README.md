# Cadherin_Junctions

* **Developed for:** Gaëtan & Alexandre
* **Team:** Germain
* **Date:** April 2023
* **Software:** Fiji


### Images description

3D images taken with a x63 objective on a widefield microscope

2 channels:
  1. *EGFP:* Cadherin junctions
  2. *DAPI:* Nuclei

### Macros description

* **Step 1:** *preprocessing.ijm:* 
  * DAPI channel: sum Z-projection + Otsu thresholding + median filtering + watersheding
  * EGFP channel: find focused slices + max z-projection
  
* **Step 2:** use *ilastik* to train a pixel classifier that can segment the EGFP channel image in 4 different classes: thin, finger, reticular and background

* **Step 3:** *postprocessing.ijm* or *postprocessing_grid.ijm + draw_grid.ijm:*
  * DAPI channel: count the number of nuclei
  * EGFP channel: measure the area of the 4 different classes (in the entire image or in each 64x64 pixels<sup>2</sup> cell of a grid)


### Version history

Version 1 released on April 26, 2023.

Version 2 released on May 10, 2023: *postprocessing_v2.ijm* or *postprocessing_v2_grid.ijm*.  
Measure the area of the 5 different classes (in the entire image or in each 64x64 pixels<sup>2</sup> cell of a grid): thin, finger, reticular, finger-reticular and background.

Version 3 released on June 8, 2023. <br />
*preprocessing.ijm*: channels corresponding to nuclei and junctions asked in a dialog box. <br />
*postprocessing.ijm* or *postprocessing_grid.ijm*: number of junctions classes asked in a dialog box.
