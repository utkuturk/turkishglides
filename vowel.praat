aantalselect = numberOfSelected ("Sound")
if 'aantalselect'!=1
   print Failure: exactly 1 Sound object should be selected!
   printline
else

selectedObj = selected()
   filterfirst = 1
   threshold = 8
name1$ = selected$ ("Sound")
Copy... temp

fs = Get sample rate
if fs>11025
  Resample... 11025 1
  Rename... temp
endif

finish = Get finishing time

if filterfirst
	Filter (one formant)... 1000 500

	Extract part... 0 'finish' Rectangular 1 1
	Rename... temp
endif

framelength = 0.01
To Intensity... 60 'framelength'
maxint = Get maximum... 0 0 Cubic
t1 = Get time from frame... 1

Down to Matrix
Rename... temp
endtime = Get highest x
ncol = Get number of columns
coldist = Get column distance

h=1
newt1 = 't1'+('h'*'framelength')
ncol = 'ncol'-(2*'h')
Create Matrix... intdot 0 'endtime' 'ncol' 'coldist' 'newt1' 1 1 1 1 1 (Matrix_temp[1,col+'h'+'h']-Matrix_temp[1,col]) / (2*'h'*dx)

To Sound (slice)... 1
Rename... temp_IntDot

select Sound temp_IntDot
To PointProcess (extrema)... Left yes no Sinc70
Rename... temp_rises

select Sound temp_IntDot
select Sound temp_IntDot
To PointProcess (zeroes)... Left no yes
Rename... temp_peaks


select PointProcess temp_peaks
Copy... temp_onsets
Remove points between... 0 'endtime'

select PointProcess temp_peaks
npeaks = Get number of points
for pindex from 1 to 'npeaks'
	select PointProcess temp_peaks
	ptime = Get time from index... 'pindex'
	select Intensity temp
	pint = Get value at time... 'ptime' Nearest
	if pint > (maxint-threshold)
		select PointProcess temp_rises
		rindex = Get low index... 'ptime'
		if rindex>0
			rtime = Get time from index... 'rindex'
			otime = ('rtime'+'ptime')/2
		else
			otime = 'ptime'
		endif # rindex>0
		select PointProcess temp_onsets
		Add point... 'otime'
		
	endif # pint>threshold
endfor # pindex from 1 to npeaks

select Sound temp
plus Intensity temp
plus Matrix temp
plus Matrix intdot
plus Sound temp_IntDot
plus PointProcess temp_rises
plus PointProcess temp_peaks
Remove
select Sound temp
Remove

select Sound temp
select Sound temp_filt
Remove
select Sound temp
Remove


select PointProcess temp_onsets
vowelStart = Get time from index: 1
vowelEnd = vowelStart + 0.07
Remove
selectObject: selectedObj
Extract part: vowelStart, vowelEnd, "rectangular", 1, "no"
extracted = selected()

To Pitch... 0.0 75 600
	writeInfoLine: "Pitch (mean):"
	meanPitch = Get mean: 0, 0, "Hertz"
        appendInfo: "    "
	appendInfo: fixed$ (meanPitch, 2)
	appendInfoLine: " Hz"
Remove

selectObject: extracted
To Formant (burg)... 0.0 5.0 5500.0 0.025 50.0

	appendInfoLine:""
	appendInfoLine: "F1 (mean):"
	meanF1 = Get mean: 1, 0, 0, "Hertz"
        appendInfo: "    "
	appendInfo: fixed$ (meanF1, 2)
	appendInfoLine: " Hz"

	appendInfoLine:""
	appendInfoLine: "F2 (mean):"
	meanF2 = Get mean: 2, 0, 0, "Hertz"
        appendInfo: "    "
	appendInfo: fixed$ (meanF2, 2)
	appendInfoLine: " Hz"

Remove
selectObject: extracted
Remove
