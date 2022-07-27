# aia-eis-venus
IDL software for scattered light calculations for AIA and EIS. 

These routines were described in the article "Scattered light in the Hinode/EIS and SDO/AIA instruments measured from the 2012 Venus transit" by Peter R. Young & Nicholeen M. Viall, which was accepted for publication in the Astrophysical Journal in July 2022.

The GitHub repository pryoung/papers/2022_venus contains examples of how to run these routines. 

## aia_annulus_int
Allows the user to choose a spatial location in an AIA "map" and an annulus centered on this location is extracted.

## eis_annulus_int
Allows the user to choose a spatial location in an EIS "map" and an annulus centered on this location is extracted.

## aia_average_full_disk
Given an AIA full disk image, this routine averages the intensity over the solar disk out to 1.1 solar radii.

## eis_aia_int_compare
Given an EIS map, the user selects a spatial location and a box centered on this location is averaged to give an intensity. An AIA image matching the EIS time is downloaded and the same spatial region is averaged. 

## eit_average_full_disk
As for aia_average_full_disk only this is for SOHO/EIT images.

## map2range
Extracts the x and y-ranges of an IDL map.

## map_pix2coord
Converts a pixel position within a map to (x,y) coordinates.
