# Hikvision-PIC-to-JPG
The purpose of this PERL script is to extract the JPG images embedded in the PIC files created by a Hikvision camera or DVR/NVR and to rename the JPG image files according to the capture date and time.

I recommend using Strawberry Perl from https://strawberryperl.com

Perl Module Requirements:  
Date::Format  
File::Find::Rule  
DBI

The required modules should come bundled with Strawberry Perl, if not you can install them using the CPAN Client.
If you are using Windows you can find the CPAN Client in the start menu. Start the CPAN Client and enter the following command:

*install Date::Format File::Find::Rule DBI*

### **To run the script start CMD and enter:**

*extract_capture.pl inputdir outputdir*

The inputdir is the folder that contains the "datadir" subfolders.  
The outputdir is the folder where the JPG files will be extracted.  
Make sure to use double quotes for the paths.
