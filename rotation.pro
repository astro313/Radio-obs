
function cool, input1, input2 , reverse = reverse, radian = radian
;
;+
;NAME = COOL
;
;PURPOSE: PERFORM TRANSFORMATION BETWEEN COORDINATE SYSTEMS 
;USING ROTATION MATRIX
;
;INPUT: input1 = first coordinate, input2= second coordinate [in RAD]
;can convert using fcn'unich'
;
;OUTPUT: new coordinates [deg], [rad] if /radian set
;
; Author : Daisy Leung
;
;-


usr = ''
read, 'Enter CONVERSION BETWEEN  1: (RA,DEC), (HA, DEC); 2:(HA, DEC), (AZ, ALT); 3: (RA, DEC), (l, b)  ', usr

R = fltarr(3,3)
x = [ [cos(input2)*cos(input1)] , [cos(input2)*sin(input1)] , [sin(input2)]]

case usr of 
    '1': begin
             R = case1(R)
         end
    '2': begin
            R = case2(R)
         end
    '3': BEGIN
            R = case3(R)
         end
     endcase

if keyword_set(reverse) then begin
   R = transpose(R)
endif
xp = R##x
cor_1 = atan(xp[1],xp[0])
cor_2 = asin(xp[2])

array = [cor_1, cor_2]
if keyword_set(radian) then begin
    array = array
 endif else begin
    array = array*!radeg
    if array[0] LT 0 then begin
       array[0] = array[0] + 360.
    endif
 endelse
print, 'The output coordinate is: ', array
return, array
end



function spec
;
;NAME: SPEC
;
;PURPOSE: CONVERT (RA, DEC) TO (AZ, ALT) FOR THE SAKE OF THIS LAB
;
;INPUT: RA, DEC
;
;OUTPUT: AZ, ALT
;
;

;h = ''
;m = ''
;s = ''
;read, 'Enter RA (h): ', h
;read, 'Enter RA (m): ', m
;read, 'Enter RA (s): ', s
;h = trim(h)
;m = trim(m)
;s = trim(s)
;ra = sex2d(h,m,s) ;to radians 

ra = double(sex2d(5,35,17))
dec = double(unich(-5,23,25))



x = double([[cos(dec)*cos(ra)] , [cos(dec)*sin(ra)] , [sin(dec)]])
x = transpose(x)
lst = ilst()*15.*!dtor  ;radian
R = double([[cos(lst), sin(lst), 0],[sin(lst),-cos(lst), 0], [0,0,1d0]])

;lat = 41.36*!dtor
lat = 37.8732d*!dtor    ;berkeley
newR = [[-sin(lat), 0, cos(lat)],[0,-1d0,0], [cos(lat),0,sin(lat)]]
R_ult = newR ## R
xpp = R_ult ## x
azi = atan(xpp[1],xpp[0])*!radeg
alt = asin(xpp[2])*!radeg

if azi LT 0 then begin
    azi = azi+360d
endif

coorda = [azi, alt]
return, coorda
end



function case1, R
;
;NAME = CASE1
;
;PURPOSE = PLUG IN NUMBERS FOR R 
;RELATING (RA, DEC) TO (HA, DEC)
;
;INPUT: R = EMPTY ARR 3X3
;
;OUTPUT: ROTATION MATRIX R
;
;
;    juls = '' 
;    read, 'Enter Julian Date for specific Julian Date, or 0 if current: ', juls
;    if juls EQ '0' then begin
        lst = lstnow()*15d0*!dtor  ;radian
;    endif else begin 
;        juls = float(juls)
;        lst = ilst(juldate = juls)
;    endelse
   
        R = [[cos(lst), sin(lst), 0],[sin(lst),-cos(lst), 0], [0,0,1d0]]

    return, R
 end

function case2, R
;
;NAME = CASE2
;
;PURPOSE = PLUG IN NUMBERS FOR R 
;RELATING (HA, DEC) and (AZ, ALT)
;
;INPUT: R = EMPTY ARR 3X3
;
;OUTPUT: ROTATION MATRIX R
;
    lat = 37.8732   ;Berkeley
    lat = lat*!dtor
    R[0,0] = -sin(lat)
    R[0,2] = cos(lat)
    R[1,1] = -1
    R[2,0] = cos(lat)
    R[2,2] = sin(lat)
    return, R
 end

function case3, R
;
;NAME = CASE3
;
;PURPOSE = PLUG IN NUMBERS FOR R 
;RELATING (RA, DEC) TO (l, b)
;
;INPUT: R = EMPTY ARR 3X3
;
;OUTPUT: ROTATION MATRIX R
;
    epoch = ''
    read, 'Enter epoch (1950 or 2000):  ', epoch
    if epoch EQ '1950' then begin
        R = [[-0.066989, -.872756, -0.483539],[0.492728,-0.450347,0.744585],[-0.867601,-0.188375,0.460200]]
    endif else begin
        R = [[-0.054876, -0.873437, -0.483835],[0.494109, -0.444830, 0.746982],[-0.867666, -0.198076, 0.455984]]
    endelse
return, R
end

function unich, degree, arcmin, arcsec
;
;
;PURPOSE: CONVERT DEGREE, arcmin, ARCSEC TO DEGREE THEN RADIAN
;
;INPUT: UNIT OF DEGREE, arcmin, ARCSEC OR JUST DEGREE
;
;OUTPUT: UNIT OF RADIAN

varia = degree + arcmin/60d0 + arcsec/3600d0   ;all in degree
varia_rad = varia*!dtor   ;radian

return, varia_rad
end


function sex2d, h, m, s
;
;PURPOSE: convert hms to degree using 'ten' with a factor of *15
;
;INPUT:  in sexahesimal
;OUTPUT:  in radian
;
result = (h*15d0+m/4d0+s/240d0)*!dtor
return, result
end







function gal2azalt

;input1 = 120 * !dtor
;input2 = 0

;input1 = unich(184,33,0)
;input2 = unich(-5,47,0)


for input2 = 20, 60, 2 do begin      ;input2 = 20 to 60
    input1 = 2./cos(input2)
    if input1 GE 60 and input1 LE 180 then begin
        usr = '3'
        result1 = cool(input1, input2, /reverse, /radian) ; ra, dec
        precess, result1[0], result1[1], 2000, 2013, /radian
        usr = '1'
        result2 = cool(result1[0], result1[1], /radian) ;ha, dec
        usr = '2'
        result3 = cool(result2[0], result2[1]) ;az, alt
        
        
        az = result3[0]
        alt = result3[1]
        
        az_rad = az * !dtor 
        alt_rad = alt * !dtor
        
        print, "az, alt in degrees : ", az, alt
    endif
endfor
    
return, result3
end

;then check with dish limit
;create huge array with az, alt
;home dish
;how many spec to take at each point?|
