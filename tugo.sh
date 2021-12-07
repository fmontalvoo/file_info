#!/bin/bash

# Author Frank Montalvo Ochoa (fmontalvoo)

#Colores
greenColor="\e[0;32m\033[1m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"
endColor="\033[0m\e[0m"

# Esta funcion itera sobre los argumentos que reciba de entrada el script.
file_iterator(){

	args=$@

	for arg in $args; do
		file_info $arg
	done

	exit 0 # Emite un codigo de salida al finalizar el script.

}

# Esta funcion extrae los permisos que posee un determinado archivo.
file_info(){

	nombre=$1 # Recibe el nombre del archivo como parametro de la funcion.

	if [ -e $nombre ]; then # Verifica que el archivo exista.

		sl=$(ls -lhd $nombre)	           # Almacena la informacion del archivo. 
		permisos=$(echo $sl | cut -c 1-10) # Recupera informacion sobre el archivo y sus permisos. 
		info=$(echo $sl | cut -c 14-)      # Recupera los metadatos del archivo.

		own_usr=$(echo $info | awk '{print $1}') # Usuario propietario
		own_grp=$(echo $info | awk '{print $2}') # Grupo propietario
		file_size=$(echo $info | awk '{print $3}') # Tamanno del archivo
		mm=$(echo $info | awk '{print $4}') # Mes de creacion
		dd=$(echo $info | awk '{print $5}') # Dia de creacion
		hh=$(echo $info | awk '{print $6}') # Hora de creacion

		t="${permisos:0:1}" # Recupera el tipo de archivo.
		u="${permisos:1:3}" # Recupera los permisos del usuario.
		g="${permisos:4:3}" # Recupera los permisos del grupo.
		o="${permisos:7:3}" # Recupera los permisos de otros.
		
		tipo=$(file_type $t) # Almacena el tipo de archivo que devuelve la funcion.

		usuario=$(file_permissions $u "u") # Almacena los permisos del usuario.
		grupo=$(file_permissions $g "g")   # Almacena los permisos del grupo.
		otro=$(file_permissions $o "o")    # Almacena los permisos de otros.

		echo -e "\n${greenColor}File${endColor}:\t\t     ${grayColor}$nombre${endColor}"
		echo -e "${greenColor}Type${endColor}:\t\t     ${grayColor}$tipo${endColor}"
		echo -e "${greenColor}Permissions${endColor}:\t     ${grayColor}$u$g$o${endColor}"
		echo -e "${greenColor}Owner user${endColor}:\t     ${grayColor}$own_usr${endColor}"
		echo -e "${greenColor}Owner group${endColor}:\t     ${grayColor}$own_grp${endColor}"
		echo -e "${greenColor}File size${endColor}:\t     ${grayColor}$file_size${endColor}"
		echo -e "${greenColor}Creation date${endColor}:\t     ${grayColor}$dd $mm $hh${endColor}\n"

		echo -e "${yellowColor}User permissions:${endColor}   $usuario\n"
		echo -e "${blueColor}Group permissions:${endColor}  $grupo\n"
		echo -e "${redColor}Others permissions:${endColor} $otro\n"
	
	else
	
		echo -e "${redColor}El archivo o directorio${endColor} ${grayColor}$nombre${endColor} ${redColor}no existe.${endColor}"
	
	fi

}

# Esta funcion regresa el tipo de archivo segun el argumento que se le pase.
file_type(){

	tipo=$1

	# Switch case que determina el tipo de archivo que recibion como parametro.
	case $tipo in
		"-") echo "Regular file";;
		"d") echo "Directory file";;
		"l") echo "Symbolic link file";;
		"b") echo "Block file";;
		"c") echo "Character device file";;
		"p") echo "Pipe file";;
		"s") echo "Socket file";;
	esac

}

# Esta funcion regresa los permisos que posee el usuario, grupo u otros sobre un determinado arhivo.
file_permissions(){

	permisos=$1    # Recibe los permisos del usuario, grupo u otros.
	propietario=$2 # Indica cual es el propietario de los permisos.

	leer="${permisos:0:1}"      # Recupera los permisos de lectura.
	escritura="${permisos:1:1}" # Recupera los permisos de escritura.
	ejecutar="${permisos:2:1}"  # Recupera los permisos de ejecucion.

	r=0 # Almacena el valor octal del permiso del lectura.
	w=0 # Almacena el valor octal del permiso de escritura.
	x=0 # Almacena el valor octal del permiso de ejecucion.

	re="" # Indica el permiso de Lectura. 
	wr="" # Indica el permiso de Escritura.
	ex="" # Indica el permiso de Ejecucion.
	
	setuid=0     # Almacena el valor del permiso de SetUID.
	setgid=0     # Almacena el valor del permiso de SetGID.
	sticky_bit=0 # Almacena el valor del permiso de Sticky Bit.

	if [ $leer = "r" ];then # Condicion para verificar que existe el permiso de lectura.
		r=4
		re="${yellowColor}Read${endColor}"
	fi

	if [ $escritura = "w" ]; then # Condicion para verificar que existe el permiso de escritura.
		w=2
		wr="${blueColor}Write${endColor}"
	fi

	if [ $ejecutar = "x" ]; then # Condicion para verificar que existe el permiso de ejecucion.
		x=1
		ex="${redColor}Execute${endColor}"
	elif [ $ejecutar = "s" -a $propietario = "u" ]; then # Condicion para verificar el permiso SetUid.
		x=1
 		setuid=4000
		ex="${yellowColor}SetUID${endColor}"
	elif [ $ejecutar = "s" -a $propietario = "g" ]; then # Condicion para verificar el permiso SetGid.
		x=1
		setgid=2000
		ex="${blueColor}SetGID${endColor}"
	elif [ $ejecutar = "t" -a $propietario = "o" ]; then # Condicion para verificar el permiso Sticky Bit.
		x=1	
		sticky_bit=1000
		ex="${redColor}Sticky Bit${endColor}"
	fi

	total=$(expr $r + $w + $x) # Suma los valores octales de cada permiso del archivo.

	# Indica los permisos que se tiene sobre el archivo.
	permisos="$re${grayColor}($leer)${endColor} $wr${grayColor}($escritura)${endColor} $ex${grayColor}($ejecutar)${endColor}"
	
	octal=$(($setuid + $setgid + $sticky_bit + $r$w$x)) # Indica los valores octales individuales que corresponden a los permisos.

	echo -e "$permisos"
	echo -e " \t\t    ${blueColor}Octal${endColor}: ${grayColor}$octal${endColor}"
	echo -e " \t\t    ${redColor}Value${endColor}: ${grayColor}$total${endColor}"

}

file_iterator $@
