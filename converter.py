#!/usr/bin/python

import re, sys, subprocess, os
import argparse

class mbp_reader():
	def __init__(self, verbose):
		self.path = os.path.dirname(os.path.realpath(__file__))
		self.verbose = verbose

	def parsefile(self, inputfile):
		#We need to go to the script's directory, as it calls other scripts in there
		mbppath = self.path + os.sep + 'lib' + os.sep + 'MBP_reader'
		os.chdir(mbppath)
		sp = subprocess.Popen(["perl", 'MBP_reader.pl' , inputfile],  stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		result, errors = sp.communicate()
		#Then we can move back to the original dir
		os.chdir(self.path)
		if self.verbose:
			print ''
			print '-----------------------------------------------------'
			print '----------- OUTPUT of MBP_Reader --------------------'
			print result
			print ''
			print '                   --- &&& ---                       '
			print 'FURTHER INFORMATION: '
			print errors
			print '-----------------------------------------------------'
			print ''
		output_contents = self.readfile(inputfile)
		return output_contents
		
	def readfile(self, inputfile):
		outputfile = inputfile + '_notes.txt'
		if self.verbose:
			print 'The output file was generated successfully: "%s"' % outputfile
		f = open(outputfile)
		filecontents = f.read()
		f.close()
		if self.verbose:
			print 'Removing the output file...'
		try:
			os.remove(outputfile)
			if self.verbose:
				print 'File removed successfully.'
		except:
			e = sys.exc_info()[0]
			print "Error: %s" % e
		return filecontents
		

class formatter():
	def __init__(self, verbose):
		self.path = os.path.dirname(os.path.realpath(__file__))
		self.verbose = verbose
		
	def convert(self, inputstream):
	
		# Split the input in several notes
		notes = inputstream.split("\n--\n")
		
		# Iterate over each note
		
		# Inside the loop, call the function parse note
		
		# The result is a note split in parts
		
		# format each single note
		
		# Build a new list with formated notes
		
		# Write the formatted note to a (temp) file, note by note
		
		# return the temp file		
		return notes

	def parsenote(self, note):
		#Perform regex
		if self.verbose:
			print "Reading the input to split the single note in its parts"
			
	def formatsinglenote(self, tornnote):
		#This function takes a dictionary with the note parts and builds one note
		pass


def main():
	argparser = argparse.ArgumentParser(description='Gets an MBP input and converts it to a valid "My Clippings.txt" file.')
	argparser.add_argument('inputfile', help='The file to convert. Inform with the full path.')
	argparser.add_argument('-o', '--output', help='The output file. If not informed, outputs to stdin.')
	argparser.add_argument('-v', '--verbose', action='store_const', const=1, default=0, help='Use this flag to get all the output to the console')
	args = argparser.parse_args()

	inputfile = args.inputfile
	output = args.output
	verbose = args.verbose
    
	# Run the MBP_parser
	myMbp = mbp_reader(verbose)
	intermediateOutput = myMbp.parsefile(inputfile)

	# Run the formatter to convert the MBP parser results into a valid My Clippings file
	myFormatter = formatter(verbose)
	results = myFormatter.convert(intermediateOutput)
	
	# If the user specified an output file, this is the time to print it. otherwise, return it to STDOUT
	
	if output:
		print 'writing output to file %s' % output
	else:
		pass #print results


if  __name__=="__main__":
	main();
	
