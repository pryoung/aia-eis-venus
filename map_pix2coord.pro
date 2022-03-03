
FUNCTION map_pix2coord, map, ix, iy

;+
; NAME:
;     MAP_PIX2COORD
;
; PURPOSE:
;     Given an IDL map, and a pixel position within this map, this
;     routine returns the solar coordinates that correspond to the
;     pixel position.
;
; CATEGORY:
;     Maps; coordinate transformation.
;
; CALLING SEQUENCE:
;     Result = MAP_PIX2COORD( Map, Ix, Iy )
;
; INPUTS:
;     Map:   An IDL map containing a 2D image.
;     Ix:    Pixel index in X-direction.
;     Iy:    Pixel index in Y-direction.
;
; OUTPUTS:
;     If an array of maps was specified, then an array of size [N,2]
;     is returned, where N is the number of elements of
;     MAP. Otherwise a 2-element array is returned. If a problem is
;     found, then -1 is returned.
;
; EXAMPLE:
;     IDL> xy=map_pix2coord(map,0,0)
;
; MODIFICATION HISTORY:
;     Ver.1, 25-Mar-2014, Peter Young
;     Ver.2, 29-Dec-2020, Peter Young
;       Added check on inputs; updated header.
;-


IF n_params() LT 3 THEN BEGIN
   print,'Use:  IDL> xy = map_pix2coord( map, ix, iy )'
   return,-1
ENDIF 

n=n_elements(map)

xc=map.xc
yc=map.yc
dx=map.dx
dy=map.dy

siz=size(map.data,/dim)
nx=siz[0]
ny=siz[1]

ixc=float(nx-1)/2.
iyc=float(ny-1)/2.

x=xc - (ixc-ix)*dx
y=yc - (iyc-iy)*dy

IF n GT 1 THEN output=[[x],[y]] ELSE output=[x,y]

return,output

END
