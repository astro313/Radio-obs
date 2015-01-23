pro observer, sun = sun, moon = moon, obj = obj

;
;NAME: OBSERVER
;
;PURPOSE: TAKE NOTES OF WHEN IT START HOMING AND WHEN IT ENDS HOMING,
;TIME THE DATA IS GOOD TO USE AND THE COORDINATIONS OF OBJECT AT THAT TIME
;
;INPUT: keyword of the object to point
;
;NOTE: startchat1, [/sun], [/moon] is the one that saved volt
;
; Was targeted for Leuschner observing nights..
;
;

home_intt = 0.5   ;half an hour in decimal time
begint = ilst()   ;1st begin time
t_arr = fltarr(1,2)
obj_cor = fltarr(1,3)
timemin = ilst()

window, 0 
!mouse.button = 0

print, 'start pro startchart1..'
wait, 1    

while !mouse.button NE 1 do begin   ;before I click the left button

   if (ilst() - begint) GT home_intt then begin ;homing
      print, 'Homing Telescopes....................'
      beginhomet = ilst()
      homer
      indi_t = [[beginhomet],[0]]
      
      
      if keyword_set(sun) then begin
         isun, alt, az, /aa     ;stores alt,az of sun
         return, alt, az
      endif
      if keyword_set(moon) then begin
         imoon, alt, az, /aa
         return, alt, az
      endif
      if keyword_set(obj) then begin ;use rotation matrix to give info on alt, az to point (if object)
         x = convert_radec2azialt()
         alt = x[1]
         az =  x[0]
      endif

      
      ptrangech, alt, az        ;point again
      indi_t(n_elements(indi_t)-1) = ilst()
      t_arr = [t_arr,indi_t]    ;append time
      save, t_arr, filename = "hometimes_obj.sav", /verbose   ;in case I break suddenly and this will save up all the home time each time since the array is appended

      print, "Done Homing"
      begint = ilst()                       ;reset begin count time for next homing        
   endif
   if (ilst() - timemin) GE 1.67e-2 then begin
      print
      print, "There are "+strcompress(round(home_intt - (ilst() - begint))*60.+" before next homing."
      print
   endif

wait, 10
   
   if keyword_set(sun) then begin
      isun, alt, az, /aa        ;stores alt,az of sun
    endif
   if keyword_set(moon) then begin
      imoon, alt, az, /aa
   endif
   if keyword_set(obj) then begin ;use rotation matrix to give info on alt, az to point (if object)
      x = convert_radec2azialt()
      alt = x[1]
      az =  x[0]
   endif
   
   ptrangech, alt, az ;point again this time useful for data analysis (more accuracy) as this time should be correcting for a very small movement from last pointing since homing
   print, 'Alt: ',alt+ 'Az: ', az 
   obj_info = [[ilst()], [alt], [az]] ;stores information of ilst(), alt, az as the data is good
   obj_cor = [obj_cor, obj_info]
   save, obj_cor, filename = "obj_info.sav", /verbose

   cursor, x, y, /nowait
   if !mouse.button EQ 1 then begin
      res = ''
      read, "Quit? (y/n)", res
      if res NE 'y' then begin
         !mouse.button = 0   ;keep in whileloop
      endif
   endif
endwhile

save, t_arr, filename = "hometimes_obj.sav", /verbose

dum = ''
read, "Name of Object pointed?   ", dum
openw, lun, strcompress('hometime_'+dum+'.txt', /remove_all), /get_lun
printf, lun, t_arr
close, lun

openw, lun, strcompress('obj_info_'+dum+.'txt', /remove_all), /get_lun
printf, lun, obj_cor 
close, lun

end



pro ptrangech, alt, az

;
;NAME:PTRANGECH
;
;PURPOSE: CHECK IF THE INPUTS RANGE CAN BE POINTED WITH TELESCOPE
;IF IT IS IN RANGE, THEN POINT
;
;INPUT: ALT, AZ
;
;OUTPUT: POINT OR ERROR
;
;

if alt GT 11 AND alt LT 87 then begin
   if az GT 72 AND az LT 259.9 then begin
      r = point2(alt= alt, az= az)    ;tells it to point to alt, az
   endif else begin
      print, 'Azimuthal angle needs to be between 72 and 315 degrees'
   endelse
endif else begin
    print, 'Altitude needs to be betwen 11 and 87 degrees'
endelse

end




function dect2st, dect

;
;NAME: DECT2ST
;
;PURPOSE: convert decimal time min or sec into standard time
;
;INPUT: decimal time min or sec
;
;OUTPUT: standard time min or sec
;
stringt = trim(dect)
pos = strpos(stringt, '.')
trimed = strmid(stringt, pos+1)
length = strlen(trimed)
extracted = float(trimed)

min = extracted/(10.*length)*3.6*length/60.  ; min in std time


pos2 = strpos(trim(min), '.')
trimed2 = strmid(trim(min), pos2+1, 2)
extracted2 = float(trimed2)

s = extracted2/100.*60.  ; s in std time

mins = [min,s]
return, mins
end


pro maintcon, dect
;
;NAME: MAINTCON
;PURPOSE: CONVERT DECIMAL TIME TO STANDARD TIME
;
;INPUT: DECIMAL TIME
;
;OUTPUT: STARDARD TIME
;
stringt = trim(dect)
pos = strpos(stringt, '.')
trimed = strmid(stringt, 0, 2)
mins = dect2st(dect)
min = mins[0]
sec = mins[1]

print, strcompress('The Standard Time of '+trim(dect)+' is '$
                   +strmid(trim(trimed),0,2)+'hr '+strmid(trim(min),0,2)+'m '$
                   +trim(sec)+'s ')
end




