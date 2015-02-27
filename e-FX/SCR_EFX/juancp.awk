#######################################################################
###                                                                 ###
### Esqueleto AWK                                                   ###
###                                                                 ###
#######################################################################
###                          I N I C I O                            ###
#######################################################################
BEGIN { inicio=0 }
#######################################################################
###                         P R O C E S O                           ###
#######################################################################
{
if (inicio==0)
  { inicio=1

    fichentrada=FILENAME  
    nomentrada=substr(fichentrada,1,index(fichentrada,".")-1)
    extentrada=substr(fichentrada,index(fichentrada,".")+1)
    nomsalida=nomentrada
    extsalida="new"
    fichsalida=nomsalida "." extsalida
    regsalida=""

fichsalida="newDataNDF.new"

  }



if ($1 ~/SSL_ET/)
  { 
     swmoneda1ok="0" 
     swmoneda2ok="0"}

# if ($0 ~/EURHUF/)
#   { swmoneda1ok="1" 
# }

# if ($0 ~/EURUSDON/)
#   { swmoneda1ok="1"
# }

 if ($0 ~/EURGBP1W/)
   { swmoneda1ok="1" 
 }
  
 if (swmoneda1ok=="1")
  { gsub(/TRADABLE/,"INDICATIVE")
  }

# gsub(/INDICATIVE/,"TRADABLE")

# if (swmoneda2ok=="1" && $0 ~/68<US>/)
#   { gsub(/16 JUN 2014/,"18 JUN 2014")
#   }


# if (swmoneda1ok=="1" && $0 ~/1691<US>/)
#    { gsub(/1691<US>250<RS>/,"1691<US>5<RS>")
#    }

# if (swmoneda2ok=="1" && $0 ~/1691<US>/)
#    { gsub(/1691<US>250<RS>/,"1691<US>10<RS>")
#    }

print $0>fichsalida

}  
  

#######################################################################
###                         F I N                                   ###
#######################################################################


END {

	close (fichsalida)

}
