
PRO map2range, map, xrange=xrange, yrange=yrange

;+
; NAME:
;     MAP2RANGE
;
; PURPOSE:
;     Takes an IDL map and works out the X-range and Y-range of the
;     image.
;
; CATEGORY:
;     Maps.
;
; CALLING SEQUENCE:
;     MAP2RANGE, Map
;
; INPUTS:
;     Map:   An IDL map containing a 2D image.
;
; OUTPUTS:
;     None.
;
; OPTIONAL OUTPUTS:
;     Xrange:  A 2-element array containing the X-range of the map in
;              the data coordinate units.
;     Yrange:  A 2-element array containing the X-range of the map in
;              the data coordinate units.
; EXAMPLE:
;     IDL> map2range, map, xrange=xrange, yrange=yrange
;
; MODIFICATION HISTORY:
;     Ver.1, 01-Aug-2014, Peter Young
;     Ver.2, 29-Dec-2020, Peter Young
;       Added input check; updated header.
;-


IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> map2range, map [, xrange=xrange, yrange=yrange ]'
   return 
ENDIF 

xc=map.xc
yc=map.yc
s=size(map.data,/dim)
nx=s[0]
ny=s[1]
dx=map.dx
dy=map.dy

x0=xc-(nx)/2.0*dx
y0=yc-(ny)/2.0*dy

xr=(nx)*dx
yr=(ny)*dy

xrange=[x0,x0+xr]
yrange=[y0,y0+yr]

END
