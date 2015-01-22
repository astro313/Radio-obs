#Updated 4/12/13
#!/usr/python
import httplib
import os
import time
    
print "hello world!"

#def websearch():
#email 
SENDMAIL = "/usr/sbin/sendmail" # sendmail location
p = os.popen("%s -t" % SENDMAIL, "w")
p.write("To: leungtszkuk@gmail.com\n")
p.write("Subject: Python can do anything\n")
p.write("\n") # blank line separating headers from body

message = "Your code has crashed.\n \n This is a new line. \n \n Python is fun. \n"
#print message
p.write(message)
sts = p.close()
if sts != 0:
    print "Sendmail exit status", sts
                 
