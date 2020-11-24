#!/bin/bash

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

		t="${permisos:0:1}" # Recupera el tipo de archivo.
		u="${permisos:1:3}" # Recupera los permisos del usuario.
		g="${permisos:4:3}" # Recupera los permisos del grupo.
		o="${permisos:7:3}" # Recupera los permisos de otros.
		
		tipo=$(file_type $t) # Almacena el tipo de archivo que devuelve la funcion.

		usuario=$(file_permissions $u "u") # Almacena los permisos del usuario.
		grupo=$(file_permissions $g "g")   # Almacena los permisos del grupo.
		otro=$(file_permissions $o "o")    # Almacena los permisos de otros.

		echo -e "\nFile: $nombre\nType: $tipo\nPermissions: $u$g$o"
		echo -e "Info:\t     $info\n"
		echo -e "User permissions:   $usuario\n"
		echo -e "Group permissions:  $grupo\n"
		echo -e "Others permissions: $otro\n"
	
	else
	
		echo "El archivo o directorio $nombre No existe."
	
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
		re="Read"
	fi

	if [ $escritura = "w" ]; then # Condicion para verificar que existe el permiso de escritura.
		w=2
		wr="Write"
	fi

	if [ $ejecutar = "x" ]; then # Condicion para verificar que existe el permiso de ejecucion.
		x=1
		ex="Execute"
	elif [ $ejecutar = "s" -a $propietario = "u" ]; then # Condicion para verificar el permiso SetUid.
 		setuid=4000
		ex="SetUID"
	elif [ $ejecutar = "s" -a $propietario = "g" ]; then # Condicion para verificar el permiso SetGid.
		setgid=2000
		ex="SetGID"
	elif [ $ejecutar = "t" -a $propietario = "o" ]; then # Condicion para verificar el permiso Sticky Bit.
		sticky_bit=1000
		ex="Sticky Bit"
	fi

	total=$(expr $r + $w + $x) # Suma los valores octales de cada permiso del archivo.

	permisos="$re($leer) $wr($escritura) $ex($ejecutar)"  # Indica los permisos que se tiene sobre el archivo.
	
	numerico=$(($setuid + $setgid + $sticky_bit + $r$w$x)) # Indica los valores octales individuales que corresponden a los permisos.

	echo -e "$permisos \n\t\t    Numeric: $numerico \n\t\t    Octal: $total"

}

file_iterator $@
