

FUNCTION eis_annulus_int, map, radius=radius, dmax=dmax, dmin=dmin, $
                          position=position, box=box

;+
; NAME:
;     EIS_ANNULUS_INT
;
; PURPOSE:
;     Allows user to select a position in an EIS intensity map, and
;     the routine computes the average intensity in an annulus around
;     this point.
;
; CATEGORY:
;     Hinode/EIS; maps.
;
; CALLING SEQUENCE:
;     Result = EIS_ANNULUS_INT( Map )
;
; INPUTS:
;     Map:   An IDL map containing the EIS image.
;
; OPTIONAL INPUTS:
;     Radius: The outer radius of the annulus in arcsec. Default is 50
;             arcsec.
;     Dmin:   The minimum intensity to display for the map.
;     Dmax:   The maximum intensity to display for the map.
;     Position: A 2-element array specifying a spatial location in the
;               EIS map. If not specified, then the user selects a
;               position by clicking with the mouse.
;     Box:    An integer. Specifies the size of a box, centered on the
;             selected location, for which the intensity is averaged. 
;	
; OUTPUTS:
;     Returns the average intensity in the annulus region. If a
;     problem is found, then -1 is returned.
;
;     Creates a two-panel IDL graphics window. The left-panel shows
;     the full map image and the user needs to select a pixel. The
;     selected pixel is then displayed on this image together with the
;     inner and outer radii of the annulus. The right panel will then
;     show the annulus image.
;
;     In the IDL command window the routine will print the annulus
;     intensity, the intensity of the selected pixel and the pixel
;     coordinates. 
;
; EXAMPLES:
;     IDL> int=eis_annulus_int(map)
;     IDL> int=eis_annulus_int(map, box=3)
;
; MODIFICATION HISTORY:
;     Ver.1, 10-May-2020, Peter Young
;     Ver.2, 18-Dec-2020, Peter Young
;       Added box= input.
;     Ver.3, 29-Dec-2020, Peter Young
;       Added check on input parameters; updated header.
;     Ver.4, 03-Mar-2022, Peter Young
;       Minor changes ready for GitHub release.
;-


IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> int=eis_annulus_int( map [, position=, radius=, dmin=, dmax=, box=] )'
   return,-1
ENDIF 

IF n_elements(radius) EQ 0 THEN radius=50.

!p.multi=[0,2,1]

a=sigrange(map.data,missing=-100,range=r)
IF n_elements(dmin) EQ 0 THEN dmin=r[0]
IF n_elements(dmax) EQ 0 THEN dmax=r[1]
plot_map,map,dmin=dmin,dmax=dmax
print,format='("   Image range: ",2f6.1)',dmin,dmax

IF n_elements(position) NE 2 THEN BEGIN 
   cursor,x,y,/data
ENDIF ELSE BEGIN
   x=position[0]
   y=position[1]
ENDELSE 
plots,x,y,psym=1,symsiz=3
u=cos(findgen(51)/50.*2.*!pi)
v=sin(findgen(51)/50.*2.*!pi)
oplot,30.*u+x,30.*v+y
oplot,radius*u+x,radius*v+y

s=size(map.data,/dim)
nx=s[0] & ny=s[1]
x0=map.xc-(nx/2.)*map.dx
y0=map.yc-(ny/2.)*map.dy

ix=findgen(nx)
iy=findgen(ny)
x_arr=(ix*map.dx + x0)#(fltarr(ny)+1.)
y_arr=(fltarr(nx)+1.)#(iy*map.dy + y0)

r_arr=sqrt( (x-x_arr)^2 + (y-y_arr)^2 )
k=where(r_arr LE 30. OR r_arr GT radius)

map2=map
data=map2.data
map2.data[k]=0.

plot_map,map2,dmin=dmin
plots,x,y,psym=1,symsiz=3

k=where(r_arr GT 30. AND r_arr LE radius)
int=average(data[k],missing=map.missing)
print,format='("   Annulus int: ",f6.2)',int

p=map_coord2pix(map,x,y)
p=round(p)
print,format='("   Pixel int: ",f6.2)',map.data[p[0],p[1]]
print,format='("   Selected pixel: [",i5,",",i5,"], coords: [",f7.1,",",f7.1,"]")',p,x,y

;
; To create the box, I need to extract the sub-map. Remember that the
; X and Y pixel sizes can be different for EIS.
;
IF n_elements(box) NE 0 THEN BEGIN
   b=round(box)
   sub_map,map,smap,xrange=x+[-b/2.,b/2.],yrange=y+[-b/2,b/2.]
   s=size(smap.data,/dim)
   print,format='("   Box size:  ",i3," x",i3)',s[0],s[1]
   print,format='("   Box int:   ",f6.2)',average(smap.data,missing=map.missing)
ENDIF 

!p.multi=0

return,int

END 
