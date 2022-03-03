
PRO eit_average_full_disk, input, radius=radius, center=center, output=output, quiet=quiet

;+
; NAME:
;     EIT_AVERAGE_FULL_DISK
;
; PURPOSE:
;     Averages the intensity over an EIT full disk image.
;
; CATEGORY:
;     SOHO/EIT.
;
; CALLING SEQUENCE:
;     EIT_AVERAGE_FULL_DISK
;
; INPUTS:
;     Input:  Either an IDL map containing a 2D prepped, full-disk EIT
;             image, or an EIT filename. In the latter case, eit_prep
;             will be run on the file.
;
; OPTIONAL INPUTS:
;     Radius:  By default, the region over which the image is averaged
;              is 1.1 solar radii. RADIUS allows this to be
;              varied. Should be given in units of the solar radius.
;     Center:  2D integer array giving the central pixel. By default
;              it is [512,512].
;
; KEYWORD PARAMETERS:
;     QUIET:  If set, then information will not be printed to the IDL
;             window, and no plots will be produced.
;
; OUTPUTS:
;     Prints to the IDL window the average intensity. A plot shows the
;     region over which the average has been computed.
;
; OPTIONAL OUTPUTS:
;     Output:  An IDL structure with the following tags:
;               .int  Average intensity (DN s-1).
;               .med_int  Median intensity (DN s-1).
;               .npix  No. of pixels used in averaging.
;               .r    Radius used in averaging.
;               .date_obs  Time of observation.
;               .exptime  Exposure time (seconds).
;
; EXAMPLE:
;     IDL> eit_average_full_disk, image
;     IDL> eit_average_full_disk, image, radius=1.05
;
; MODIFICATION HISTORY:
;     Ver.1, 29-Dec-2020, Peter Young
;-


IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> eit_average_full_disk, input [, /quiet, center=, radius=, output= ]'
   print,''
   print,'   Input  - either an IDL map, or an EIT filename'
   return
ENDIF 

CASE datatype(input) OF
  'STR': BEGIN
    eit_prep,input,index,data
    index2map,index,data,map
  END
  'STC': map=input
ENDCASE 

img=map.data
s=size(img,/dim)
nx=s[0]
ny=s[1]

IF nx NE ny THEN BEGIN
  print,'% EIT_AVERAGE_FULL_DISK: The EIT image size is non-standard ('+trim(nx)+','+trim(ny)+'). Returning...'
  return
ENDIF 

IF n_elements(radius) EQ 0 THEN rcheck=1.1 ELSE rcheck=radius
IF n_elements(pix_size) EQ 0 THEN pix_size=map.dx
IF n_elements(center) EQ 0 THEN center=[nx/2,nx/2]


ix=findgen(nx)
iy=findgen(ny)

ident=fltarr(nx)+1.

ix_arr=ix#ident
iy_arr=ident#iy

r=sqrt( (ix_arr-center[0])^2 + (iy_arr-center[1])^2 )/960.*pix_size


IF NOT keyword_set(quiet) THEN BEGIN 
  plot_image,sigrange(img)
  theta=findgen(1001)/1000.*2.*!pi
  x=center[0] + rcheck*960./pix_size *sin(theta)
  y=center[1] + rcheck*960./pix_size *cos(theta)
  oplot,x,y
ENDIF 


k=where(r LE rcheck,nk)
int=average(img[k])
IF NOT keyword_set(quiet) THEN print,format='("Average intensity: ",f7.2)',int


output={ npix: nk, $
         int: int, $
         med_int: median(img[k]), $
         r: rcheck, $
         exptime: map.dur, $
         date_obs: map.time }

END

