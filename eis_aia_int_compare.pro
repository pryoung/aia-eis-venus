
PRO eis_aia_int_compare, emap, amap, bdim=bdim, position=position, output=output, quiet=quiet, $
                         eis_dark=eis_dark, aia_time=aia_time, aia_sub_map=aia_sub_map, $
                         aia_offset=aia_offset, eis_scale=eis_scale


;+
; NAME:
;     EIS_AIA_INT_COMPARE
;
; PURPOSE:
;     Given EIS and AIA maps, this routine extracts the average
;     intensities for the same spatial locations in each.
;
; CATEGORY:
;     EIS; AIA comparison.
;
; CALLING SEQUENCE:
;     EIS_AIA_INT_COMPARE, Emap
;
; INPUTS:
;     Emap:   The EIS map formed from the Fe XII 195 line.
;
; OPTIONAL INPUTS:
;     Amap:   The AIA 193 full-disk map. If not specified, then the
;             nearest AIA synoptic file is downloaded and read.
;     Bdim:   The dimension of the box used for the averaging. The
;             default is 30 arcsec.
;     Position: A 2-element array specifying the spatial location to
;               be used for determining the average intensity. If set,
;               then the user is not asked to click on a position in
;               the EIS image.
;     Aia_Time: If this is set, then the routine searches for the AIA
;               file closest to this time, rather than the time of the
;               EIS raster.
;     Aia_Offset: A 2-element array specifying the spatial offset to
;                 apply to the sub-map box.
;     Eis_Dark:  An intensity to subtract from the EIS intensity.
;     Eis_Scale: A float specifying a scale factor to multiply the EIS
;                intensity by. Young & Ugarte-Urra (2022) suggested a
;                factor of 0.86 for 40" slot data.
;	
; OUTPUTS:
;     In the graphics window, the EIS map is plotted on the left-hand
;     side, and the user has to click on a location. The AIA sub-map
;     matching the EIS image is shown on the right-side, with the
;     selected region shown.
;
;     In the IDL window, the routine prints:
;       - average intensity of selected EIS region.
;       - average intensity in AIA 193 image for selected EIS region.
;       - average full disk 193 intensity (from
;         aia_average_full_disk).
;       - the EIS full disk intensity (obtained by scaling relative to
;         AIA). 
;
; OPTIONAL OUTPUTS:
;     Aia_Sub_Map:  Contains the sub-map for AIA that matches the
;                   input EIS map.
;     Output:   A structure containing the results. The tags are:
;                .t_eis  Time of EIS data.
;                .t_aia  Time of AIA image.
;                .x      X-center of box.
;                .y      Y-center of box.
;                .bdim   Dimensions of box.
;                .int_eis  Average EIS intensity inside box.
;                .int_aia  Average AIA intensity inside box.
;                .int_aia_fd  Full-disk AIA intensity.
;                .int_eis_fd  Full-disk EIS intensity.
;
; MODIFICATION HISTORY:
;     Ver.1, 07-Dec-2020, Peter Young
;     Ver.2, 08-Dec-2020, Peter Young
;        Added position=, output= and /quiet.
;     Ver.3, 18-Dec-2020, Peter Young
;        Now downloads EIT data if AIA not available.
;     Ver.4, 02-Mar-2022, Peter Young
;        Fixed bug when /quiet is set; added eis_scale= optional
;        input. 
;-


IF n_elements(bdim) EQ 0 THEN bdim=30

IF NOT keyword_set(quiet) THEN window,0,xsize=1200,ysize=600
IF n_elements(aia_offset) EQ 0 THEN aia_offset=[0,0]

IF n_elements(eis_scale) EQ 0 THEN eis_scale=1.0

!p.multi=[0,2,1]

k=where(emap.data NE emap.missing)
dmin=min(emap.data[k])
IF NOT keyword_set(quiet) THEN plot_map,emap,/log,dmin=max([10,dmin])

IF n_elements(position) EQ 0 THEN BEGIN 
   cursor,x,y,/data,/down
ENDIF ELSE BEGIN
   x=position[0]
   y=position[1]
ENDELSE 

dd=bdim/2
IF NOT keyword_set(quiet) THEN oplot,x+[-dd,dd,dd,-dd,-dd],y+[-dd,-dd,dd,dd,-dd]

sub_map,emap,semap,xrange=[x-dd,x+dd],yrange=[y-dd,y+dd],/noplot

;----
;
; Note that I read the synoptic image with sdo2map, rather than use
; the output from eis_mapper_aia_map. This is because the latter is
; not normalized.
;
aia_flag=0b
eit_flag=0b
IF n_tags(amap) EQ 0 THEN BEGIN
   IF n_elements(aia_time) NE 0 THEN search_time=aia_time ELSE search_time=emap.time
   dmap=eis_mapper_aia_map(search_time,193,/quiet,/no_delete,local_file=local_file)
  ;
   IF n_tags(dmap) EQ 0 THEN BEGIN
      amap=eis_mapper_eit_map(search_time,195,/quiet)
      IF n_tags(amap) NE 0 THEN eit_flag=1b
   ENDIF ELSE BEGIN 
      amap=sdo2map(local_file)
      junk=temporary(dmap)
      file_delete,local_file
   ENDELSE 
ENDIF ELSE BEGIN
  ;
  ; If AMAP was input to the routine, then check the map ID to
  ; see if it's EIT.
  ;
   chck=strpos(amap.id,'EIT')
   IF chck GE 0 THEN eit_flag=1b
ENDELSE

;
; This check is in case the AIA image is partial frame (not relevant
; to EIT).
;
IF NOT eit_flag THEN BEGIN 
   chck=finite(amap.data,/nan)
   k=where(chck EQ 1,nk)
   junk=temporary(chck)
   IF nk GE 100000l THEN aia_flag=1b
ENDIF 


;
; In case there's a significant difference between the EIS and
; AIA images, I rotate the EIS coordinates and then work out the
; xrange and yrange that's applied to AIA.
;
newxy=rot_xy(emap.xc,emap.yc,tstart=emap.time,tend=amap.time)
map2range,emap,xrange=xr,yrange=yr
dx=newxy[0]-emap.xc
dy=newxy[1]-emap.yc
xrange=dx+xr & yrange=dy+yr
sub_map,amap,samap,xrange=xrange,yrange=yrange


IF NOT keyword_set(quiet) THEN plot_map,samap,/log
IF NOT keyword_set(quiet) THEN oplot,x+dx+[-dd,dd,dd,-dd,-dd]+aia_offset[0],y+dy+[-dd,-dd,dd,dd,-dd]+aia_offset[1]

sub_map,samap,samap2,/noplot, $
        xrange=x+dx+[-dd,dd]+aia_offset[0], $
        yrange=y+dy+[-dd,dd]+aia_offset[1]
;sub_map,samap,samap2,xrange=[x-dd,x+dd]+aia_offset[0],yrange=[y-dd,y+dd]+aia_offset[1],/noplot

;
; Average the AIA/EIT image over the full-disk (out to 1.05 solar
; radii). 
;
IF eit_flag THEN BEGIN
   eit_average_full_disk,amap,/quiet,radius=1.05,output=aiadata
ENDIF ELSE BEGIN 
   aia_average_full_disk,amap,/quiet,output=aiadata, radius=1.05
ENDELSE 
   
IF n_elements(eis_dark) NE 0 THEN eis_subtract=eis_dark ELSE eis_subtract=0.

int_eis=(average(semap.data)-eis_subtract)*eis_scale
int_eis_fd=aiadata.int/average(samap2.data)*int_eis
scale_factor=int_eis_fd/12.51

IF NOT keyword_set(quiet) THEN BEGIN
   print,format='("EIS average intensity: ",f7.2)',int_eis
   print,format='("AIA average intensity: ",f7.2)',average(samap2.data)
   print,format='("AIA full-disk intensity: ",f7.2)',aiadata.int
   print,format='("EIS full-disk intensity (inferred): ",f7.2)',int_eis_fd
   print,format='("Scale factor: ",f7.2)',scale_factor
ENDIF


output={t_eis: emap.time, $
        t_aia: amap.time, $
        x: x, $
        y: y, $
        bdim: bdim, $
        int_eis: int_eis, $
        int_aia: average(samap2.data), $
        int_aia_fd: aiadata.int, $
        int_eis_fd: int_eis_fd }

!p.multi=0


aia_sub_map=temporary(samap)


IF aia_flag EQ 1 THEN print,'**WARNING: AIA map contains a large missing block! Try a different time.'

print,format='("Solar position selected: ",2f7.1)',x,y

END
