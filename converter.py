#!/usr/bin/python

import re, sys, subprocess, os

print 'Usage: convert.py <input> <output>'

input_file = str(sys.argv[1])
output_file = str(sys.argv[2])
#print input_file

my_path = os.path.dirname(os.path.realpath(__file__))

os.chdir('MBP_Reader') #Go down to the module directory to run the PERL script
pipe = subprocess.Popen(["perl", "MBP_reader.pl", input_file],  stdout=subprocess.PIPE)
result = pipe.stdout.read()
os.chdir('..') #Go back to the Python script dir
#print result
output_txt = input_file + '_notes.txt'

f = open(output_txt)
file_contents = f.read()
f.close()

converted_contents = ''
#Regex substitution starts

notes = file_contents.split("\n--\n")
print notes

#Regex ends

f2 = open(output_file,'w')
f2.write(converted_contents)
f2.close()
