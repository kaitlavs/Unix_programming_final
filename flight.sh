#!/bin/bash

#Kaitlyn Lavan
#Tracking flights in ireland
#cisc3130 final project
#4.25.18


#sets the background back to black and white when the program ends
trap 'tput setab 0; tput setaf 7; exit' SIGTERM SIGINT SIGQUIT
 

clear


#gets the data from opensky for the flights
wget -qO- https://opensky-network.org/api/states/all >f1
sed s/"],"/"],\n"/g < f1 >f2 								#separates data into individual lines
grep Ireland f2 >f3									#puts all the flights taking off from Ireland in one file
sed 's/\"//g' < f3 >f4									#takes out all quotation marks
sed 's/[[:space:]]//g' f4 | head -20 > f5						#takes out spaces that interfere with line recognition 



tput cup 1 50;										#position for title
tput setab 2; tput setaf 0; echo "~~~~ F L I G H T S    D E P A R T I N G     I R E L A N D ~~~~"	#coloring for title
tput setab 0;
tput setaf 7;

while true
do
   row=5										#sets row, colomn, and counter every run through
   colm=6
   counter=1

   for line in `cat f5`								 	#each line in f5 runs through
   do
	
	flightNum=`echo $line | awk -F, '{print $2}' | sed 's/\"//g'i | cut -c1-40`	
	country=`echo $line   | awk -F, '{print $3}' | cut -c1-40`
	ground=`echo $line    | awk -F, '{print $9}' | cut -c1-40`
	airline=`echo $line   | awk -F, '{print $2}' | cut -c 1-3` 	
	latitude=`echo $line  | awk -F, '{print $7}' | cut -c1-40` 	
	longitude=`echo $line | awk -F, '{print $6}' | cut -c1-40`


	#color coded by airline 
	if [ "$airline" = "RYR" ]
	then
   	   tput setab 1;
   	   tput setaf 7;
	elif [ "$airline" = "AZA" ]
	then
	   tput setab 2;
	   tput setaf 1;
	elif [ "$airline" = "SAS" ]
	then 
	   tput setab 4;
	   tput setaf 1;
	elif [ "$airline" = "IBK" ]
	then
	   tput setab 1;
	   tput setaf 0;
	elif [ "$airline" = "EIN" ]
	then
	   tput setab 7;
	   tput setaf 0;
	elif [ "$airline" = "ISS" ]
	then
	   tput setab 4;
	   tput setaf 1;
	elif [ "$airline" = "TAY" ]
	then
	   tput setab 3;
	   tput setaf 0;
	elif [ "$airline" = "ABR" ]	
	then
	   tput setab 6;	
	   tput setaf 0;  
	elif [ "$airline" = "SDM" ]
	then
	   tput setab 4;
	   tput setaf 0;
	else 
	   tput setab 0;
           tput setaf 7;
	fi
		

	#first line of data outputs the Flight Number
	tput cup $row $colm;
	echo "                                     "
	tput cup $row $colm;
	echo "Flight Number: $flightNum                                           "
	row=$((row+1))

	#second row of data outputs the airline designated by the first three letters of the Flight Number
	tput cup $row $colm;
	echo "                     i                                           "
	tput cup $row $colm;
	if [ "$airline" = "RYR" ]   
	then
	   echo "Airline: Ryanair                                              "
	elif [ "$airline" = "AZA" ]
	then
	  echo "Airline: Alitalia                                              "
	elif [ "$airline" = "SAS" ]
	then
	  echo "Airline: Scandinavian Airline      s                           " 
	elif [ "$airline" = "IBK" ]
	then
	  echo "Airline: Norwegian Air Internationa      l                     "
	elif [ "$airline" = "EIN" ]
	then
	  echo "Airline: Aer Lingus                                            " 
	elif [ "$airline" = "ISS" ]
	then
	  echo "Airline: Meridiana                                             "
	elif [ "$airline" = "TAY" ]
	then
	  echo "Airline: TNT Airways                                           "
	elif [ "$airline" = "ABR" ]
	then
	  echo "Airline: ASL Airlines Ireland                                  "
	elif [ "$airline" = "SDM" ]
	then
	  echo "Airline: Rossiya                                               "
	else
	  echo "Airline: DATA UNAVAILABLE                                      "  
	fi
	row=$((row+1))
	

	#Second line printed tells you if it has landed or if it is enroute
	tput cup $row $colm;
	echo "                                                  "
	tput cup $row $colm;
	if [ "$ground" = "true" ]
	then
	   echo "Status: Landed                                                   " 
	else
	   echo "Status: En route                                                 " 
	fi
	row=$((row+1))
	
	#checks to see if location data is available
	if [ "$latitude" = "null" ] || [ "$longitude" = "null" ]
	then
	   tput cup $row $colm;
	   echo "                                                          "
	   tput cup $row $colm;
	   echo " - NO LOCATION DATA -                "
	   row=$((row+1))
	else	
	#if location data is available, webscrapes the address from nominatim -- reverse genocoding website 
	   wget -qO- "http://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1" >m1
	   sed s/","/",\n"/g < m1 > m2
	   sed 's/[[:space:]]//g' m2 > m3
	

	   house=`cat m2    | grep house    | awk -F: '{print $3}' | sed 's/\"//g' |sed s/","/" "/g | cut -c1-10` 
	   road=`cat m2     | grep road     | awk -F: '{print $3}' | sed 's/\"//g' | sed s/","/" "/g | cut -c1-10`
	   country=`cat m2  | grep country  | head -1 | awk -F: '{print $2}' | sed 's/\"//g' | sed s/","/" "/g | cut -c1-10`
	   postcode=`cat m2 | grep postcode | awk -F: '{print $2}' | sed 's/\"//g' | sed s/","/" "/g | cut -c1-10`
	
	   #if country tag does not exist then outputs no data	
	   if [ "$country" = "" ]
	   then
	      tput cup $row $colm;   
	      echo "                                                                 "
	      tput cup $row $colm;
	      echo " - NO LOCATATOIN DATA -         "	
	      row=$((row+1))
	   else
	      #outputs the address, country and postcode 
	      tput cup $row $colm;
	      echo "                                                                 "
	      tput cup $row $colm;
	      echo "Address: $country $postcode                                  " 
	      row=$((row+1))
	   fi
	fi
		
	#increments the counter everytime through the loop in order to change position of the next output line
	counter=$((counter+1))

	#colm 1
	if [ $counter -eq 2 ]
	then
   	   row=10
	   colm=6
	fi
 
	if [ $counter -eq 3 ]
	then
   	   row=15
	   colm=6
	fi
	   
	if [ $counter -eq 4 ]
	then
   	   row=20
	   colm=6
	fi

	if [ $counter -eq 5 ]
	then
	   row=25
	   colm=6
	fi

	#colm 2	
	if [ $counter -eq 6 ]
	then
	   row=5
	   colm=85
	fi

	if [ $counter -eq 7 ]
	then
	   row=10
	   colm=85
	fi

	if [ $counter -eq 8 ]
	then
	   row=15
	   colm=85
	fi


	if [ $counter -eq 9 ]
	then
	  row=20
	  colm=85
	fi

	if [ $counter -eq 10 ]
	then
	  row=25
	  colm=85
	  counter=1
	fi
   sleep 2

   done
# resets positioning

   sleep 5

done

