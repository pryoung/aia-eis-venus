
PRO aia_average_full_disk, img, radius=radius, center=center, index=index, quiet=quiet, output=output

;+
; NAME:
;     AIA_AVERAGE_FULL_DISK
;
; PURPOSE:
;     Averages the intensity over an AIA full disk image.
;
; CATEGORY:
;     SDO/AIA
;
; CALLING SEQUENCE:
;     AIA_AVERAGE_FULL_DISK
;
; INPUTS:
;     Img:  An IDL map structure containing a full-disk AIA image. Can
;           also be a 2D image, although in this case it is
;           recommended that the input INDEX is given.
;
; OPTIONAL INPUTS:
;     Radius:  By default, the region over which the image is averaged
;              is 1.1 solar radii. RADIUS allows this to be
;              varied. Should be given in units of the solar radius.
;     Center:  2D integer array giving the central pixel. By default
;              it is [512,512].
;     Index:   The index structure obtained when reading an AIA image
;              with read_sdo. Only needed if IMG was set as a 2D
;              image. 
;	
; OUTPUTS:
;     Prints to the IDL window the average intensity. A plot shows the
;     region over which the average has been computed.
;
; OPTIONAL OUTPUTS:
;     A structure with the tags:
;      .npix   No. of pixels used for average.
;      .int    The average intensity (DN/s).
;      .med_int The median intensity (DN/s).
;      .r      The radius used (unts of solar radius).
;      .exptime  The exposure time (seconds).
;
; EXAMPLE:
;     IDL> map=sdo2map(filename)
;     IDL> aia_average_full_disk, map
;     IDL> aia_average_full_disk, map, radius=1.05
;
; MODIFICATION HISTORY:
;     Ver.1, 29-Dec-2020, Peter Young
;-


IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> aia_average_full_disk, input [, /quiet, center=, index=, radius=, output= ]'
   print,''
   print,'   Input  - an IDL map containing a full disk image'
   return
ENDIF 

;
; The input IMG can be a 2D image, but it is recommended that a map is
; input. 
;
IF n_tags(img) EQ 0 THEN BEGIN
  image=img
  exptime=1.0
  IF n_tags(index) EQ 0 THEN BEGIN
     pix_size=0.60
     date_obs=''     
  ENDIF ELSE BEGIN
     pix_size=index.cdelt1
     date_obs=index.date_obs
  ENDELSE 
ENDIF ELSE BEGIN
  image=img.data
  exptime=img.dur
  pix_size=img.dx
  date_obs=img.time
ENDELSE 

IF n_elements(radius) EQ 0 THEN rcheck=1.1 ELSE rcheck=radius


s=size(image,/dim)
CASE 1 OF
   s[0] EQ 4096 AND s[1] EQ 4096: BEGIN
      npix=4096
      IF n_elements(center) EQ 0 THEN center=[2047,2047]
   END 
   s[0] EQ 1024 AND s[1] EQ 1024: BEGIN
      npix=1024
      IF n_elements(center) EQ 0 THEN center=[511,511]
   END
   ELSE: print,'% AIA_AVERAGE_FULL_DISK: The input image needs to be 4096x4096 or 1024x1024. Returning...'
ENDCASE 


ix=findgen(npix)
iy=findgen(npix)

ident=fltarr(npix)+1.

ix_arr=ix#ident
iy_arr=ident#iy

r=sqrt( (ix_arr-center[0])^2 + (iy_arr-center[1])^2 )/960.*pix_size


IF n_tags(index) NE 0 THEN exptime=index.exptime


output={ npix: 0l, $
         int: 0., $
         med_int: 0., $
         r: rcheck, $
         exptime: exptime, $
         date_obs: date_obs}


k=where(r LE rcheck AND image GE 0.,nk)
output.npix=nk
output.int=average(image[k])/exptime
output.med_int=median(image[k])/exptime

ratio=output.int/output.med_int


IF NOT keyword_set(quiet) THEN BEGIN 
  plot_image,alog10(image),dmin=10
  theta=findgen(1001)/1000.*2.*!pi
  x=center[0] + rcheck*960./pix_size *sin(theta)
  y=center[1] + rcheck*960./pix_size *cos(theta)
  oplot,x,y
 ;
 ; I found an image (6-Jun-2012, 16:55) where a fraction of the image
 ; was set to -32768. (I think the CCD section was not being
 ; downloaded). 
 ;
  print,'No. of pixels used in average: ',output.npix
  print,format='("Average intensity: ",f9.2)',output.int
ENDIF 

END

