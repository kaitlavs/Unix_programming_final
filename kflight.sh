#!/bin/bash

#
e find a Jet Blue flight to trak
#
#
#
# color codes for shell script
#
# 0 - Black
# 1 - Red
# 2 - Green
# 3 - Yellow
# 4 - Blue
# 5 - Magenta
# 6 - Cyan
# 7 - White
#
e
   friend bool operator ==(const rational& op1, const rational& op2);
#
# try to set the terminal back to normal
#
trap 'tput setab 0; tput setaf 7; exit' SIGTERM SIGINT SIGQUIT

if [ $# -eq 1 ]
then
   debug=true
else
   debug=false
fi

clear

rm -f errlog.txt
rm -f t1

wget -qO- https://opensky-network.org/api/states/all >a1
sed s/"],"/"],\n"/g < a1 > a2
grep JBU a2 > a3
sed s/" "/"_"/g <a3 >a4

row=1
colm=6
counter=0
displayColm=1

firstTime=1

#
# 4 = blue, 7 = white
#
tput setab 4;
tput setaf 7;

while true
do
   for line in `cat a4`
   do
      if [ $debug = "true" ]
      then
         echo "---------------------------------------------------------------------" >> errlog.txt
         echo $line                                                                   >> errlog.txt
      fi
     
      transponder=`echo $line | cut -c3-8`
      flightNum=`echo $line   | awk -F, '{print $2}'`
      country=`echo $line     | awk -F, '{print $3}'`
      onTheGround=`echo $line | awk -F, '{print $9}'`

      if [ $debug = "true" ]
      then
         echo "trans=$transponder" >> errlog.txt
         echo "flight=$flightNum" >> errlog.txt
         echo "country=$country" >> errlog.txt
      fi

      if [ $onTheGround = "true" ]
      then
         echo "$transponder : On The Ground" >> errlog.txt
         continue
      fi

      #
      # 1st line of flight data
      #
      tput cup $row $colm;
      echo "                                                              "
      tput cup $row $colm;
      fltNum=`echo $flightNum | sed s/"_"/" "/g`
      echo "$fltNum                                  $country"
 
      wget -qO- https://opensky-network.org/api/states/all?icao24=$transponder >t1
      if [ $debug = "true" ]
      then
         cat t1 >> errlog.txt
      fi

      size=`cat t1 | wc -c | awk '{print $1}'`
      if [ $size -gt 60 ]
      then
         latitude=`cat t1 | awk -F, {'print $8}'`
         longitude=`cat t1 | awk -F, {'print $7}'`

         if [ $latitude = "null" ] || [ $longitude = "null" ]
         then 
            continue
         fi

         if [ $debug = "true" ]
         then
            echo "lat=$latitude  long=$longitude" >> errlog.txt
         fi
 
         wget -qO- http://maps.google.com/maps/api/geocode/xml?latlng=$latitude,$longitude\&sensor=false >g1
         location=`grep "<formatted_address>" g1 | head -1 | sed s/"<formatted_address>"/""/g | sed s/"<\/formatted_address>"/""/g`

         if [ $debug = "true" ]
         then
            cat g1 >> errlog.txt
         fi

         if [ $debug = "true" ]
         then
            echo "LOC=$location" >> errlog.txt
         fi

         row=$((row + 1))

         size=`echo $location | wc -c | awk '{print $1}'`
         if [ $size -gt 10 ]
         then
            tput cup $row $colm;
            echo "                                                              "
            tput cup $row $colm;
            echo $location | cut -c1-62
         else
            if [ $firstTime -eq 1 ]
            then
               tput cup $row $colm;
               echo "   - NO LOCATION DATA -                                       "
            fi
         fi

         row=$((row + 2))
      else
         echo "$transponder : Open Sky Data is too small" >> errlog.txt
         cat t1                                           >> errlog.txt

         row=$((row + 1))
         tput cup $row $colm;
         echo "                                                              "

         row=$((row + 2))
      fi

      counter=$((counter + 1))
      if [ $counter -eq 14 ]
      then
         if [ $displayColm -eq 1 ]
         then
            displayColm=2

            row=1
            colm=72
            counter=0
         else
            break
         fi
      fi

      sleep 4
   done


   #
   # reset flag
   #
   firstTime=0

   sleep 10

   #
   # start display all over again
   #
   displayColm=1
   row=1
   colm=6
   counter=0
done
