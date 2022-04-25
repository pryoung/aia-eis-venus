
FUNCTION aia_annulus_int, smap, position=position, show=show, $
                          outer_radius=outer_radius, $
                          inner_radius=inner_radius, output=output, $
                          ann_map=ann_map


;+
; NAME:
;     AIA_ANNULUS_INT
;
; PURPOSE:
;     Allows the user to select a spatial location in an AIA map, and
;     an annulus region is extracted. The average intensity in this
;     region is returned. Intended to be used for estimating scattered
;     light in AIA 193 images.
;
; CATEGORY:
;     AIA; scattered light.
;
; CALLING SEQUENCE:
;     Result = AIA_ANNULUS_INT( Map )
;
; INPUTS:
;     Map:   An IDL map containing an AIA image. Due to the small size
;            of the annulus, it is recommended that you first create a
;            sub-map from an AIA image.
;
; OPTIONAL INPUTS:
;     Position:  A 2-element array containing spatial coordinates. If
;                set, then the user will not be asked to choose a
;                pointing with the mouse.
;     Inner_Radius: A float specifying the inner radius of the annulus
;                   in arcsec. Default is 30 arcsec.
;     Outer_Radius: A float specifying the outer radius of the annulus
;                   in arcsec. Default is 50 arcsec.
;	
; KEYWORD PARAMETERS:
;     SHOW:   If set, then an image of the annulus region will be displayed.
;
; OUTPUTS:
;     Returns the average intensity inside the annulus in units of DN
;     s^-1. If a problem is found, then -1 is returned.
;
; OPTIONAL OUTPUTS:
;     Output:  A structure containing the following tags:
;               .int_ann  The annulus intensity (same as output).
;               .inner_radius  Inner radius (arcsec).
;               .outer_radius  Outer radius (arcsec).
;               .int_loc_avg   Intensity at specified position,
;                              averaged over 5"x5" block.
;               .int_loc_med   Median intensity over the 5"x5" block.
;               .time_stamp    Time at which routine was run.
;
;      Ann_Map:  An IDL map containing only the annulus image (this is
;                displayed when /show is set).
;
; MODIFICATION HISTORY:
;     Ver.1, 29-Dec-2020, Peter Young
;     Ver.2, 07-Apr-2022, Peter Young
;       Added ANN_MAP= optional output.
;-



IF n_params() LT 1 THEN BEGIN
   print,'Use:  IDL> output=aia_annulus_int( map [, /show, inner_radius=, outer_radius=, position=,'
   print,'                                     output=, ann_map= ] )'
   return,-1
ENDIF 

IF n_elements(outer_radius) EQ 0 THEN outer_radius=50.
IF n_elements(inner_radius) EQ 0 THEN inner_radius=30.

IF n_elements(position) EQ 2 THEN BEGIN
   xpos=position[0]
   ypos=position[1]
ENDIF ELSE BEGIN
   plot_map,smap,/log
   print,'Please choose a center for the annulus...'
   cursor,xpos,ypos,/data
   plots,xpos,ypos,symsize=3,psym=1
   print,format='("  ...selected position [",f6.1,",",f6.1,"].")',xpos,ypos
ENDELSE 
   

s=size(smap.data,/dim)
v_ix=round( (xpos-smap.xc)/smap.dx ) + round(s[0]/2.)
v_iy=round( (ypos-smap.yc)/smap.dy ) + round(s[1]/2.)
x_arr=findgen(s[0])#(fltarr(s[1])+1.)
y_arr=(fltarr(s[0])+1.)#findgen(s[1])
r_arr=sqrt( (v_ix-x_arr)^2 + (v_iy-y_arr)^2 )
k=where(r_arr GT inner_radius/smap.dx AND r_arr LE outer_radius/smap.dy,nk)
print,'No. of pixels in annulus: ',nk
out_int=average(smap.data[k])


ind=findgen(201)/200.*2.*!pi
xci=inner_radius*cos(ind)+xpos
yci=inner_radius*sin(ind)+ypos
oplot,xci,yci
;
ind=findgen(201)/200.*2.*!pi
xci=outer_radius*cos(ind)+xpos
yci=outer_radius*sin(ind)+ypos
oplot,xci,yci


k=where(r_arr LE  inner_radius/0.6 OR r_arr GT outer_radius/0.6)
ann_map=smap
ann_map.data[k]=0.
IF keyword_set(show) THEN BEGIN 
   plot_map,ann_map,title='Annulus map'
ENDIF 

IF smap.dur NE 1.0 THEN BEGIN
   print,format='("Exposure time is: ",f7.2," seconds. Intensity will be converted to DN s^-1.")',smap.dur
   out_int=out_int/smap.dur
ENDIF 


;
; Extract a sub-map at POSITION, and compute average and median
; intensity. Use a 5x5 arcsec^2 block
;
sub_map,smap,xmap,xrange=[xpos-2.5,xpos+2.5],yrange=[ypos-2.5,ypos+2.5]
int_loc_avg=mean(xmap.data)
int_loc_med=median(xmap.data)

output={ int_ann: out_int, $
         inner_radius: inner_radius, $
         outer_radius: outer_radius, $
         position: [xpos, ypos], $
         int_loc_avg: int_loc_avg, $
         int_loc_med: int_loc_med, $
         time_stamp: systime() }

return,out_int

END
