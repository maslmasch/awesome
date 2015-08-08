#! /usr/bin/env python 
# Tells the shell with which interpreter the script should be run when started with ./

import subprocess
import string
import sys
import os


if __name__ == '__main__':
    xrandr_output = subprocess.check_output(["xrandr"],universal_newlines=True)
    xrandr_output = xrandr_output.splitlines(False)
    connected_devices = []
    device_options = [] 
    for i in range(len(xrandr_output)-1,-1,-1):
        if "disconnected" in xrandr_output[i] or "Screen" in xrandr_output[i]: del xrandr_output[i]

    i=0
    while True:    
        if " connected" in xrandr_output[i]:
            tmp=xrandr_output[i].split(' ',1)
            connected_devices.append(tmp[0])
            i+=1
            tmp = []
            while True:
                if i==len(xrandr_output) or " connected" in xrandr_output[i]: break
                tmp.append(((xrandr_output[i].lstrip()).split(' ',1))[0])
                i+=1
            device_options.append(tmp)
        if i==len(xrandr_output): break


    f = open('workfile' ,'w')
    f.write("#! /bin/bash \n\nfoo=\"xrandr --output\"\n\necho \"Which device do you want to change?\"\nselect device in \"")
    for i in range(0,len(connected_devices),1): f.write(connected_devices[i] + "\" \"")
    f.write("cancel\"; do\n    case $device in \n")
    for i in range(0,len(connected_devices),1):
        f.write("        " + connected_devices[i] + " ) foo=\"$foo " + connected_devices[i] + " \" ;choice="+str(i)+"; break;;\n")
    f.write("        cancel ) exit;;\n    esac\ndone\n")   
    


    # Mode
    f.write("echo \"Choose a mode.\"\n")
    for i in range(0,len(connected_devices),1):
        f.write("\nif [ \"$choice\" == "+str(i)+" ];\nthen\n    select mode in ")
        for j in range(0, len(device_options[i]),1):
            f.write("\""+(device_options[i])[j]+"\" ")
        f.write(" \"off\" \"cancel\"; do")
        f.write("\n        case $mode in\n")
        for j in range(0, len(device_options[i]),1):
            f.write("            "+(device_options[i])[j]+" ) foo=\"$foo --mode "+(device_options[i])[j]+"\"; break;;\n")
        f.write("            off ) foo=\"$foo --off\";miau=1; break;;\n")
        f.write("            cancel ) exit;;\n        esac\n    done\nfi\n") 
    f.write("if [ \"$miau\" == \"1\" ] \nthen\n    $foo\n    exit\nfi\n")
    
    #location location location 
    f.write("echo \"Where do you want it?\"\n")
    f.write("select loc in \"right-of\" \"left-of\" \"above\" \"below\" \"cancel\"; do\n")
    f.write("    case $loc in\n")
    f.write("        right-of ) foo=\"$foo --right-of\"; break;;\n")
    f.write("        left-of ) foo=\"$foo --left-of\"; break;;\n")
    f.write("        above ) foo=\"$foo --above\"; break;;\n")
    f.write("        below ) foo=\"$foo --below\"; break;;\n")
    f.write("        cancel ) exit;;\n")
    f.write("    esac\ndone\n")
    


    # corresponding display
    f.write("echo \"Corresponding to which device?\"\n")
    for i in range(0,len(connected_devices),1):
        f.write("\nif [ \"$choice\" == "+str(i)+" ];\nthen\n    select port in ")
        for j in range(0, len(connected_devices),1):
            if j == i: continue
            f.write("\""+connected_devices[j]+"\" ")
        f.write(" \"off\" \"cancel\"; do")
        f.write("\n        case $port in\n")
        for j in range(0, len(connected_devices),1):
            if j == i: continue
            f.write("            "+connected_devices[j]+" ) foo=\"$foo "+connected_devices[j]+"\"; break;;\n")
        f.write("            cancel ) exit;;\n        esac\n    done\nfi\n") 

    f.write("$foo")

    os.popen("urxvt -e bash workfile")
    sys.exit()





