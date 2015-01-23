;
;
; Created in 2012
; Author: Daisy Leung
;
; Based on python email.py
; Purpose: Email self when IDL crashes, or any errors 
;
;


pro emailme

   catch, error_status

   if error_status ne 0 then begin
       print, "Oh no! Code crashed! Silly Leuschner."
       print, !error_state.msg    ;tells what issue like socket or function...
       print
       print, "I'll email you now."
       spawn, 'python email.py'     ; execute python email script
       print, "You have mail!"
;       catch, /cancel

       ;you can put a goto statement here to re-try observing 
;       goto, convenientplace
   endif


   ;observing code goes here
   print, "...I'm observing....."
   wait, 2
   print, "**** BOOMMMM... something BAD happens."
   wait, 2

   dfka ;jibberish to make IDL crash
   
   convenientplace:
   print, "I've returned down to here."

end

