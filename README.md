Ancient Lives Processing Pipeline
-----------------------------------

The Ancient Lives Processing Pipeline is a suite of software that has been created to transform the inputs from citizen scientists in the Ancient Lives project into usable transcriptions.   This software was developed at the University of Minnesota Supercomputing Center and Middle Tennessee State University.

To convert the clicks into a consensus transcription, there are a number of steps.   

1) A database snapshot from the Ancient Lives project is downloaded from Amazon. So far, this typically is done by the Zooniverse team in Chicago.   The format for this file is a mysql dump file. 



2) Once the dumpfile has been created, it needs to be read into mysql for processing.   A series of simple SQL commands is used to extract a text dump of selected fields containing the user id, fragment ids, character position, and character identification.   This file is a unicode text file that is human and machine readable.   This extracted text file is named "markers.txt" and is reasonably large (198 MB) as of 02-Dec-2013.

	# extract the data from the SQL database - the assumption is that database is called pap2013 
	# and has already been imported into sql.   The output file is put into /tmp/markers.txt
	
	# from MySQL - assumes the dump file has been read in already
	use pap2013;
	select user_id, fragment_id, x, y, (`character`) from markers where x is not null and y is not null and `character` is not null and `character`<>"" and x<>"" and y<>"" and x>0 and y>0
	into outfile '/tmp/markers.txt'
	fields terminated by ','
	lines terminated by '\n';
	exit;

    # Query run on Sequel Pro in my MacBook took ~1 minute to run, but crippled my laptop for roughly 20 minutes when asked to export it. 

    use ancientlives;
	select user_id, fragment_id, x, y, (`character`) from markers where x is not null and y is not null and `character` is not null and `character`<>"" and x<>"" and y<>"" and x>0 and y>0


3) The program converts the markers file from unicode into plain text using the "convert2ascii.py" program.   This program replaces unicode character with a numerical value.  We use the convert2ascii.py program as a command line utility and pipe the output to a file called "converted.txt".


	# convert the unicode to a character file
	python convert2ascii.py > converted.txt



4) The system then sorts the "converted.txt" file create two new files.   One of the files is sorted by the fragment ID number and the other is sorted by the user id.   The file names are "converted_by_frag.txt" and "converted_by_user.txt".   


	# create some helper files for arranging the data into subdirectories
	sort -n -k2,2 -t,  converted.txt > converted_by_frag.txt
	sort -n -k1,1 -t,  converted.txt > converted_by_user.txt



5) Statistics are calculated by the "statistics.py" and "hist.py" programs.   Numbers including the number of clickers per fragment and the number of users per fragment are created.   The output file "fragmentStatistics.txt" is created by the "statistics.py" program.   The "hist.py" file creates a "hist.txt" text file to make it easier to examine the cumulative statistics for the current data dump.


	# do some basic statisical analysis on the number of users and clicks per fragment
	python statistics.py
	python hist.py
	
	# create a new helper file of fragments sorted by the number of users
	sort -n -k3,3 -t, fragmentStatistics.txt > sortedFragments.txt 




6) As an option, scripts are included to make summary plots of the current data dump.   It can be loaded within gnuplot or Python to produce graphs.

	# plotting in GNUPLOT
	gnuplot < pfile

    # plotting in Python
    python plot_stats.py
	
	
	
	
7) The "separate.py" python program separates the documents by the number of users that have contributed to each document.   The number of documents in each group is hard-coded within the code.   The output of this file is a series of files with lists of fragments in them.  The file names from the program is of the form "fragX_Y.txt", where X is the minimum and Y is the maximum number of users for the fragments listed within the file.   


	# separate the fragments into files fragX_Y.txt which contain \ge X and \le Y users
	python separate.py




8) A matlab script is used to read the original unicode file into a Matlab database.   This step creates a large but well-indexed file that is used for subsequent processing.   This takes roughly 10 minutes on the MSI computer for the data as of Dec 2013. 

	# Create the matlab database in an interactive session

    # Note: make sure the header line is stripped and quotation marks removed from the "markers.txt" file

    isub -n nodes=1:ppn=4 -m 16GB -w 24:00:00
	module load matlab
	matlab -nodesktop -nosplash -r "make_db"

    ####### PROBLEM #######

    The version of Matlab on MSI is not reading the SQL output properly in "read_fragments_mod.m" (which is called by make_db). The purpose is to import a CSV file into a Matlab database, which should be simple. The problem is that the cell array in John's code is not recognizing the Greek unicode characters. It can be read into Matlab, but when saving as a cell array, it gets converted to a gibberish "[]" character. Frustrating, and means that all the results from the KDE don't work on the new data. - KW, 12 Dec 2013

    Seems fixed now - the gibberish "[]" character is differentiable, but not in the interactive environment. Still annoying.

9) A program called "setupdirectories.py" creates a set of directories and portable batch script (PBS) files that are used to process the data.   The PBS scripts copy critical data into the subdirectories and then execute "process_directories_serial.m" for the fragment groups.   It then creates a set of transcription files using the "createLines.py" program.   Before executing, the scripts run the "restart.py" script.  This script ensures than only unprocessed files are put through the processing pipeline effectively checkpointing the code.


	# setup the directories and files
	python setupdirectories.py


10) Finally, you can start the batch jobs to do the processing.   Individual "pbs" files can also be submitted.   For details, look at the PBS_master file.


	# process the data
	chmod 755 PBS_master
	./PBS_master
 
