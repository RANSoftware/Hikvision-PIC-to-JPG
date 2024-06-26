#!/usr/bin/perl -

use Date::Format;
use File::Find::Rule;
use DBI;
#use Data::Dumper qw(Dumper);

my ($mainInputDir, $outputDir) = @ARGV;

if (not defined $mainInputDir) {
  die "\nERROR: Need input directory.\nThe input directory should be the directory that contains the datadir folders.\nUsage: extract_capture.pl inputdir outputdir\n";
}

if (not defined $outputDir) {
  die "\nERROR: Need output directory.\nUsage: extract_capture.pl inputdir outputdir\n";
}

my $useMainInputDir = 0;

unless ((-e $mainInputDir."/datadir0/event_db_index01") or (-e $mainInputDir."/datadir0/pic_segment_db_index00000") or (-e $mainInputDir."/datadir0/index00p.bin") or (-e $mainInputDir."/datadir0/index01p.bin")) {
	$useMainInputDir = 1;
	unless ((-e $mainInputDir."/event_db_index01") or (-e $mainInputDir."/pic_segment_db_index00000") or (-e $mainInputDir."/index00p.bin") or (-e $mainInputDir."/index01p.bin")) {
		die "\nERROR: Can't find event_db_index01 or pic_segment_db_index00000 or index00p.bin or index01p.bin in $mainInputDir\\datadir0\ or $mainInputDir\n";
	}
}

print "\n************* EXTRACTION DATE AND TIME LIMITS *************\n";
print "\nDate and time format example YYYYMMDDHHMMSS: 20181225221508\n";
print "\nEnter START date and time (or enter 1 to start from the\nfirst available image or leave empty if you don't want to use\na date and time limit): ";
my $inputStartDate = <STDIN>;
chomp $inputStartDate;

$nowEndDate = time2str("%Y%m%d%H%M%S", time());

if ($inputStartDate != "") {
	print "\nEnter END date and time (or enter 1 to use current date and\ntime (this will extract until the last image), or leave empty\nif you don't want to use a date and time limit): ";
	our $inputEndDate = <STDIN>;
	chomp $inputEndDate;
	if ($inputEndDate == 1) {
		$inputEndDate = $nowEndDate;
	}
}

print "\n************* OUTPUT JPG FILES NAMING OPTIONS (DEFAULT 1) *************\n";
print "\nEnter 1 for Image_YYYY_MM_DD-HH_MM_SS-DayName.jpg\nEx: Image_2018_12_25-22_15_08-Tue.jpg\n";
print "\nEnter 2 for Image_YYYYMMDDHHMMSS-DayNumber.jpg\nEx: Image_20181225221508-2.jpg\n";
my $outputDateFormat = <STDIN>;
chomp $outputDateFormat;

print "\n************* WHEN MORE THAN ONE PICTURE IS TAKEN PER SECOND (DEFAULT 1) *************\n";
print "\nEnter 1 to auto rename and keep all pictures\n";
print "\nEnter 2 to only save the first picture\n";
my $timeDuplicates = <STDIN>;
chomp $timeDuplicates;

my @datadirArray = File::Find::Rule->directory->in($mainInputDir);
@datadirArray = sort @datadirArray;
if ($useMainInputDir == 0) {
	@datadirArray = @datadirArray[ 1 .. $#datadirArray ];
}
my $datadirNumber = @datadirArray;

if ($useMainInputDir == 1) {
	print "The input directory you have specified doesn't contain datadir folders,\nbut will be processed since it contains index files.\nThe input directory should be the directory that contains the datadir folders.\n\n";
}

print "Number of found datadirs: ", $datadirNumber, "\n";
for ($i=0; $i<$datadirNumber; $i++) {
		print $datadirArray[$i], "\n\n"
}

for ($i=0; $i<$datadirNumber; $i++) {
	my $inputDir = $datadirArray[$i];
	print "Processing folder: $inputDir\n";

	if (-e $inputDir."/event_db_index01") {
		my $ary1;
		my $TBNumber;
		sleep(2);

		my $driver = "SQLite"; 
		my $database = $inputDir . "/event_db_index01";
		my $dsn = "DBI:$driver:dbname=$database";
		my $userid = "";
		my $password = "";
		my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
		
		my $sth = $dbh->table_info('','main','%', 'TABLE');
		my $tables = [map{$_->[2]} @{$sth->fetchall_arrayref()}];
		#print join("\n", @$tables);
		
		if ( grep( /^event_id$/, @$tables ) ) {
			print "\n\n***** event_id found *****\n";
			my $stmt = qq(SELECT id, event_table_name from event_id;);
			my $sth = $dbh->prepare($stmt);
			my $rv = $sth->execute() or die $DBI::errstr;
				if($rv < 0) {
					print $DBI::errstr;
				}
			$ary1 = $sth->fetchall_arrayref({});
			#print Dumper(\$ary1);		
		}
		
		else {
			print "\nCan't find event_id, using the predefined detection tables.",
			"\nThis method may produce fewer images than your .pic files actually contain.",
			"\nYou can open an issue on my github page at",
			"\nhttps://github.com/RANSoftware/Hikvision-PIC-to-JPG/issues",
			"\nand attach your event_db_index01 file.",
			"\nThe script will resume in 10 seconds.\n";
			sleep(10);
			$ary1 = [
				{
				  'id' => 9,
				  'event_table_name' => 'MoveDetectionDB'
				},
				{
				  'id' => 10,
				  'event_table_name' => 'MotionDetectTB'
				},
				{
				  'id' => 11,
				  'event_table_name' => 'AlarminTB'
				},
				{
				  'id' => 12,
				  'event_table_name' => 'AlarmInputTB'
				},
				{
				  'id' => 13,
				  'event_table_name' => 'SceneChangeTB'
				},
				{
				  'id' => 23,
				  'event_table_name' => 'NormalPirDB'
				},
				{
				  'id' => 24,
				  'event_table_name' => 'NormalPirTB'
				},
				{
				  'id' => 194,
				  'event_table_name' => 'faceSnapDB'
				},
				{
				  'id' => 204,
				  'event_table_name' => 'intrusionDB'
				},
				{
				  'id' => 205,
				  'event_table_name' => 'lineCrossDB'
				},
				{
				  'id' => 206,
				  'event_table_name' => 'regionEnterDB'
				},
				{
				  'id' => 207,
				  'event_table_name' => 'regionExitDB'
				},
				{
				  'id' => 208,
				  'event_table_name' => 'loiteringDB'
				},
				{
				  'id' => 209,
				  'event_table_name' => 'peopleGatherDB'
				},
				{
				  'id' => 210,
				  'event_table_name' => 'fastMoveDB'
				},
				{
				  'id' => 211,
				  'event_table_name' => 'ParkingDB'
				},
				{
				  'id' => 212,
				  'event_table_name' => 'objectLeaveDB'
				},
				{
				  'id' => 213,
				  'event_table_name' => 'objectRemoveDB'
				},
				{
				  'id' => 234,
				  'event_table_name' => 'MdWithTargetDB'
				},
				{
				  #---------- Extract first picture only ----------
				  'id' => 240,
				  'event_table_name' => 'FaceDetectionCaptureTable'
				},
				{
				  #---------- Extract first picture only ----------
				  'id' => 241,
				  'event_table_name' => 'FaceDetectTB'
				},
				{
				  'id' => 280,
				  'event_table_name' => 'SceneChangeDetectionDB'
				},
				{
				  'id' => 449,
				  'event_table_name' => 'IntrusionCaptureTable'
				},
				{
				  'id' => 450,
				  'event_table_name' => 'LineCrossCaptureTable'
				},
				{
				  'id' => 451,
				  'event_table_name' => 'RegionEnterCaptureTable'
				},
				{
				  'id' => 452,
				  'event_table_name' => 'RegionExitCaptureTable'
				},
				{
				  'id' => 453,
				  'event_table_name' => 'LoiteringCaptureTable'
				},
				{
				  'id' => 454,
				  'event_table_name' => 'PeopleGatherCaptureTable'
				},
				{
				  'id' => 455,
				  'event_table_name' => 'FastMoveCaptureTable'
				},
				{
				  'id' => 456,
				  'event_table_name' => 'ParkingCaptureTable'
				},
				{
				  'id' => 457,
				  'event_table_name' => 'ObjectLeaveCaptureTable'
				},
				{
				  'id' => 458,
				  'event_table_name' => 'ObjectRemoveCaptureTable'
				},
				{
				  'id' => 460,
				  'event_table_name' => 'TimingCaptureTB'
				},
				#------------------- Unknown id -------------------
				{
				  'id' => 1000,
				  'event_table_name' => 'ManualCaptureTB'
				},
				{
				  'id' => 1001,
				  'event_table_name' => 'MdWithTargetCaptureTable'
				},
				{
				  #---------- Extract first picture only ----------
				  'id' => 1002,
				  'event_table_name' => 'mixedTrafficDetectTB'
				}
			];
		}
		
		$TBNumber = $#$ary1 + 1;
		print "\nNumber of tables in database: $TBNumber\n";
		sleep(1);
		my $tableName;
		for ($j=0; $j<$TBNumber; $j++) {
			$tableName = $ary1->[$j]{'event_table_name'};
			if ($tableName ne "certificateRevocationTable") {
				if ( grep( /^$tableName$/, @$tables )) {
					print "\n***** $tableName found *****\n";
					print "Processing table: $tableName: ";
					my $stmt = "SELECT id, trigger_time, file_no, pic_offset_0, pic_len_0 from ".$tableName;
					my $sth = $dbh->prepare($stmt) or die $DBI::errstr;
					my $rv = $sth->execute();
					
					if($rv < 0) {
					   print $DBI::errstr;
					}
					$ary = $sth->fetchall_arrayref({});

					my $TBLength = $#$ary + 1;
					print "$TBLength\n";
					sleep(1);
					
					for ($k=0; $k<$TBLength; $k++) {
						$fileNumber = $ary->[$k]{'file_no'};
						$picFileName = "hiv" . sprintf("%05d", $fileNumber) . ".pic";
						open (PF, $inputDir . "/" . $picFileName) or die "ERROR: Can't find " .$picFileName. " in the input folder.\n";
						binmode(PF);
						$capDate = $ary->[$k]{'trigger_time'};
						$startOffset = $ary->[$k]{'pic_offset_0'};
						$endOffset = $startOffset + ($ary->[$k]{'pic_len_0'});
						$formatted_start_time = time2str("%C", $capDate, -0005);
						if ($outputDateFormat == 1) {
							$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
							$fileDayofWeek = time2str("%a", $capDate, -0005);
						}
						elsif ($outputDateFormat == 2) {
							$fileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
							$fileDayofWeek = time2str("%w", $capDate, -0005);
						}
						else {
							$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
							$fileDayofWeek = time2str("%a", $capDate, -0005);
						}
						$limitFileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
										
						if ($inputStartDate != "" and $inputEndDate != "") {
							if ($capDate > 0 and $limitFileDate >= $inputStartDate and $limitFileDate <= $inputEndDate) {
								$jpegLength = ($endOffset - $startOffset);
								$fileSize = $jpegLength / 1024;
								$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
								if ($timeDuplicates != 2) {
									my $picNumber = 1;
									START:
										if (-e $outputDir."/".$fileName) {
										print "File Exists! Renaming...\n";
										$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
										$picNumber++;
										goto START;
										}
								}
								unless (-e $outputDir."/".$fileName) {
									if ($jpegLength > 0) {
										seek (PF, $startOffset, 0);
										read (PF, $singlejpeg, $jpegLength);
										print "PicFile: $picFileName\n";
										if ($singlejpeg =~ /[^\0]/) {
											print "POSITION (".($k+1)."): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
											open (OUTFILE, ">". $outputDir."/".$fileName);
											binmode(OUTFILE);
											print OUTFILE ${singlejpeg};
											close OUTFILE;
										}
									}
								}
							}
						} 
						else {
							if ($capDate > 0) {
								$jpegLength = ($endOffset - $startOffset);
								$fileSize = $jpegLength / 1024;
								$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
								if ($timeDuplicates != 2) {
									my $picNumber = 1;
									START:
										if (-e $outputDir."/".$fileName) {
										print "File Exists! Renaming...\n";
										$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
										$picNumber++;
										goto START;
										}
								}
								unless (-e $outputDir."/".$fileName) {
									if ($jpegLength > 0) {
										seek (PF, $startOffset, 0);
										read (PF, $singlejpeg, $jpegLength);
										print "PicFile: $picFileName\n";
										if ($singlejpeg =~ /[^\0]/) {
											print "POSITION (".($k+1)."): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
											open (OUTFILE, ">". $outputDir."/".$fileName);
											binmode(OUTFILE);
											print OUTFILE ${singlejpeg};
											close OUTFILE;
										}
									}
								}
							}
						}
						close (PF);
					}
				}
				else {
					print "\nCan't find table: $tableName\n";
				}
			}
			else {
				print "\n***** $tableName found *****\n";
				print "$tableName will not be processed because it's not a detection table.\n";
				}
		}
		$dbh->disconnect();
		print "Operation done for folder: $inputDir\n";
	}

	elsif (-e $inputDir."/pic_segment_db_index00000") {
		our $pic_segment_index = 0;
		while (1) {
			my $pic_segment_filename = sprintf("pic_segment_db_index%05d", $pic_segment_index);
			my $pic_segment_filepath = $inputDir . "/" . $pic_segment_filename;
			
			if (-e $pic_segment_filepath) {
				perform_extraction($pic_segment_filepath);
			}   
			else {
				last;
			}
			$pic_segment_index++;
		}

		sub perform_extraction {
			my $driver = "SQLite"; 
			my ($database) = @_;
			print "Processing: $database\n\n";
			my $dsn = "DBI:$driver:dbname=$database";
			my $userid = "";
			my $password = "";
			my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
			my $stmt = "SELECT start_time, start_offset, end_offset from "."pic_segment_idx_tb";
			my $sth = $dbh->prepare($stmt) or die $DBI::errstr;
			my $rv = $sth->execute();
			
			if($rv < 0) {
				print $DBI::errstr;
			}
			$ary = $sth->fetchall_arrayref({});

			my $TBLength = $#$ary + 1;
			#print "$TBLength\n";
			#sleep(2);
			
			for ($k=0; $k<$TBLength; $k++) {
				$picFileName = "hiv" . sprintf("%05d", $pic_segment_index) . ".pic";
				#print "$picFileName\n";
				#sleep(2);
				open (PF, $inputDir . "/" . $picFileName) or die "ERROR: Can't find " .$picFileName. " in the input folder.\n";
				binmode(PF);
				$capDate = $ary->[$k]{'start_time'};
				$startOffset = $ary->[$k]{'start_offset'};
				$endOffset = $ary->[$k]{'end_offset'};
				$formatted_start_time = time2str("%C", $capDate, -0005);
				if ($outputDateFormat == 1) {
					$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
					$fileDayofWeek = time2str("%a", $capDate, -0005);
				}
				elsif ($outputDateFormat == 2) {
					$fileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
					$fileDayofWeek = time2str("%w", $capDate, -0005);
				}
				else {
					$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
					$fileDayofWeek = time2str("%a", $capDate, -0005);
				}
				$limitFileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
								
				if ($inputStartDate != "" and $inputEndDate != "") {
					if ($capDate > 0 and $limitFileDate >= $inputStartDate and $limitFileDate <= $inputEndDate) {
						$jpegLength = ($endOffset - $startOffset);
						$fileSize = $jpegLength / 1024;
						$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
						if ($timeDuplicates != 2) {
							my $picNumber = 1;
							START:
								if (-e $outputDir."/".$fileName) {
								print "File Exists! Renaming...\n";
								$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
								$picNumber++;
								goto START;
								}
						}
						unless (-e $outputDir."/".$fileName) {
							if ($jpegLength > 0) {
								seek (PF, $startOffset, 0);
								read (PF, $singlejpeg, $jpegLength);
								print "PicFile: $picFileName\n";
								if ($singlejpeg =~ /[^\0]/) {
									print "POSITION (".($k+1)."): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
									open (OUTFILE, ">". $outputDir."/".$fileName);
									binmode(OUTFILE);
									print OUTFILE ${singlejpeg};
									close OUTFILE;
								}
							}
						}
					}
				} 
				else {
					if ($capDate > 0) {
						$jpegLength = ($endOffset - $startOffset);
						$fileSize = $jpegLength / 1024;
						$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
						if ($timeDuplicates != 2) {
							my $picNumber = 1;
							START:
								if (-e $outputDir."/".$fileName) {
								print "File Exists! Renaming...\n";
								$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
								$picNumber++;
								goto START;
								}
						}
						unless (-e $outputDir."/".$fileName) {
							if ($jpegLength > 0) {
								seek (PF, $startOffset, 0);
								read (PF, $singlejpeg, $jpegLength);
								print "PicFile: $picFileName\n";
								if ($singlejpeg =~ /[^\0]/) {
									print "POSITION (".($k+1)."): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
									open (OUTFILE, ">". $outputDir."/".$fileName);
									binmode(OUTFILE);
									print OUTFILE ${singlejpeg};
									close OUTFILE;
								}
							}
						}
					}
				}
				close (PF);
			}
			$dbh->disconnect();
		}
	print "Operation done for folder: $inputDir\n";
	}

	elsif ((-e $inputDir."/index00p.bin") or (-e $inputDir."/index01p.bin")) {	
				
		$maxRecords = 4096;
		$recordSize = 80;

		open (FH,$inputDir . "/index00p.bin") or (print "\n\nCan't find index00p.bin, trying to use index01p.bin...\n" and open (FH,$inputDir . "/index01p.bin")) or die "ERROR: Can't find index00p.bin or index01p.bin in the input folder.\n";
		read (FH,$buffer,1280);
		#read (FH,$buffer,-s "index00.bin");

		($modifyTimes, $version, $picFiles, $nextFileRecNo, $lastFileRecNo, $curFileRec, $unknown, $checksum) = unpack("Q1I1I1I1I1C1176C76I1",$buffer);
		#print "$modifyTimes, $version, $picFiles, $nextFileRecNo, $lastFileRecNo, $curFileRec, $unknown, $checksum\n";

		$currentpos = tell (FH);
		$offset = $maxRecords * $recordSize;
		$fullSize = $offset * $picFiles;

		for ($l=0; $l<$fullSize; $l++) {
				seek (FH, $l, 0); #Use seek to make sure we are at the right location, 'read' was occasionally jumping a byte
				$Headcurrentpos = tell (FH);
				read (FH,$Headbuffer,80); #Read 80 bytes for the record
				#print "************$Headcurrentpos***************\n";
						
				($Headfield1, $Headfield2, $Headfield3, $Headfield4, $Headfield5, $Headfield6, $HeadcapDate, $Headfield8, $Headfield9, $Headfield10, $Headfield11, $Headfield12, $Headfield13, $Headfield14, $HeadstartOffset, $HeadendOffset) = unpack("I*",$Headbuffer);
						
				#print "$Headercurrentpos: $Headfield1, $Headfield2, $Headfield3, $Headfield4, $Headfield5, $Headfield6, $HeadcapDate, $Headfield8, $Headfield9, $Headfield10, $Headfield11, $Headfield12, $Headfield13, $Headfield14, $HeadstartOffset, $HeadendOffset\n";
				if ($HeadcapDate > 0 and $Headfield8 == 0 and $Headfield9 > 0 and $Headfield10 == 0 and $Headfield11 == 0 and $Headfield12 == 0 and $Headfield13 == 0 and $Headfield14 == 0 and $HeadstartOffset > 0 and $HeadendOffset > 0)
				{
					$fullSize = 1;
					$headerSize = $Headcurrentpos - $recordSize;
					print "\nHeaderSize: $headerSize\nStarting...\n\n";
					sleep (3);
				}
		}
		
		for ($m=0; $m<$picFiles; $m++) {
			my $LastCapDate = 0;
			$newOffset = $headerSize + ($offset * $m);
			seek (FH, $newOffset, 0);
			$picFileName = "hiv" . sprintf("%05d", $m) . ".pic";
			print "PicFile: $picFileName at $newOffset\n";
			open (PF, $inputDir . "/" . $picFileName) or die "ERROR: Can't find " . $picFileName . " in the input folder.\n";
			binmode(PF);
				
			for ($n=0; $n<$maxRecords; $n++) {
				$recordOffset = $newOffset + ($n * $recordSize); #get the next record location
				seek (FH, $recordOffset, 0); #Use seek to make sure we are at the right location, 'read' was occasionally jumping a byte
				$currentpos = tell (FH);
				read (FH,$buffer,80); #Read 80 bytes for the record
				#print "************$currentpos***************\n";
						
				($field1, $field2, $field3, $field4, $field5, $field6, $capDate, $field8, $field9, $field10, $field11, $field12, $field13, $field14, $startOffset, $endOffset) = unpack("I*",$buffer);
				
				$formatted_start_time = time2str("%C", $capDate, -0005);
				if ($outputDateFormat == 1) {
					$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
					$fileDayofWeek = time2str("%a", $capDate, -0005);
				}
				elsif ($outputDateFormat == 2) {
					$fileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
					$fileDayofWeek = time2str("%w", $capDate, -0005);
				}
				else {
					$fileDate = time2str("%Y_%m_%d-%H_%M_%S", $capDate, -0005);
					$fileDayofWeek = time2str("%a", $capDate, -0005);
				}
				$limitFileDate = time2str("%Y%m%d%H%M%S", $capDate, -0005);
				
				#print "$currentpos: $field1, $field2, $field3, $field4, $field5, $field6, $capDate, $field8, $field9, $field10, $field11, $field12, $field13, $field14, $startOffset, $endOffset\n";
				
				if ($inputStartDate != "" and $inputEndDate != "") {
					if ($capDate > 0 and $capDate > $LastCapDate and $limitFileDate >= $inputStartDate and $limitFileDate <= $inputEndDate) {
						$jpegLength = ($endOffset - $startOffset);
						$fileSize = $jpegLength / 1024;
						$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
						if ($timeDuplicates != 2) {
							my $picNumber = 1;
							START:
								if (-e $outputDir."/".$fileName) {
								print "File Exists! Renaming...\n";
								$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
								$picNumber++;
								goto START;
								}
						}
						unless (-e $outputDir."/".$fileName) {
							if ($jpegLength > 0) {
								seek (PF, $startOffset, 0);
								read (PF, $singlejpeg, $jpegLength) or last;
								if ($singlejpeg =~ /[^\0]/) {
									print "POSITION ($currentpos): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
									open (OUTFILE, ">". $outputDir."/".$fileName);
									binmode(OUTFILE);
									print OUTFILE ${singlejpeg};
									close OUTFILE;
								}
							}
						}
						if ($LastCapDate < $capDate) {
						$LastCapDate = $capDate;
						}
					}
				} 
				else {
					if ($capDate > 0 and $capDate > $LastCapDate) {
						$jpegLength = ($endOffset - $startOffset);
						$fileSize = $jpegLength / 1024;
						$fileName = "Image_${fileDate}-${fileDayofWeek}.jpg";
						if ($timeDuplicates != 2) {
							my $picNumber = 1;
							START:
								if (-e $outputDir."/".$fileName) {
								print "File Exists! Renaming...\n";
								$fileName = "Image_${fileDate}-${fileDayofWeek}-". sprintf("%03d", $picNumber) .".jpg";
								$picNumber++;
								goto START;
								}
						}
						unless (-e $outputDir."/".$fileName) {
							if ($jpegLength > 0) {
								seek (PF, $startOffset, 0);
								read (PF, $singlejpeg, $jpegLength) or last;
								if ($singlejpeg =~ /[^\0]/) {
									print "POSITION ($currentpos): $formatted_start_time - OFFSET:($startOffset - $endOffset)\nFILE NAME: $fileName FILE SIZE: ". int($fileSize)." KB\n\n";
									open (OUTFILE, ">". $outputDir."/".$fileName);
									binmode(OUTFILE);
									print OUTFILE ${singlejpeg};
									close OUTFILE;
								}
							}
						}
						if ($LastCapDate < $capDate) {
						$LastCapDate = $capDate;
						}
					}
				}
			}
			close (PF);
		}
		close FH;
	}
	else {	
		die "\nERROR: Can't find event_db_index01 or pic_segment_db_index00000 or index00p.bin or index01p.bin in $inputDir\n";
	}
}
print "\nAll operations completed.\n";
