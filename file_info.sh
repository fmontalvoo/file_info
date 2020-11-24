#!/bin/bash

file_info(){

	nombre=$1 # Recibe el nombre del archivo como parametro de la funcion.

	if [ -e $nombre ]; then # Verifica que el archivo exista.

		sl=$(ls -ld $nombre)	# Almacena la informacion del archivo. 
		info=$(echo $sl | cut -c 1-10)	# Recupera informacion sobre el archivo y sus permisos. 

		t="${info:0:1}"	# Recupera el tipo de archivo.
		u="${info:1:3}"	# Recupera los permisos del usuario.
		g="${info:4:3}"	# Recupera los permisos del grupo.
		o="${info:7:3}"	# Recupera los permisos de otros.
		
		tipo=$(file_type $t)
		echo $tipo


	
	else
	
		echo "El archivo o directorio $nombre No existe."
	
	fi

}

file_type(){

	tipo=$1

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

file_info $@
