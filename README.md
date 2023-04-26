# Cadherin_Junctions

* **Developed for:** Gaëtan & Alexandre
* **Team:** Germain
* **Date:** April 2023
* **Software:** Fiji


### Images description

2D images taken with a x63 objective on a widefield microscope

2 channels:
  1. *EGFP:* Cadherin junctions
  2. *DAPI:* Nuclei

### Macros description

* Step 1: *preprocessing.ijm:* 
  a. DAPI channel: sum Z-projection + Otsu thresholding + median filtering + watersheding
  b. EGFP channel: find focused slices + max z-projection
  
* Step 2: Use ilastik


### Version history

Version 1 released on April 26, 2023.
