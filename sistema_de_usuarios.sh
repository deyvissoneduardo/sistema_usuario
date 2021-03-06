#!/usr/bin/env bash
#
# sistema_de_usuarios.sh - simula um banco de dados .txt
#
# Autor:      Deyvisson Eduardo
# Manutenção: Deyvisson Eduardo
#
# ------------------------------------------------------------------------ #
#  Este programa irá simular um banco de dados com intuito de aprondunda conhecimentos em shell
#
#  Exemplos:
#      $ ./sistema_de_usuarios.sh InsertUser 1:teste:teste@gmail.com
#      Inseri um usuario no banco.txt.
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 09/02/2021, Deyvisson:
#       - Início do programa
#       - Funcionalidades de Inserir e excluir
#	v1.1 13/02/2021, Deyvisson:
#	    - Implementado Dialog
#       - Menu Principal
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.0.8
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #
DATABASE="banco.txt"
SEP=:
MSGN_SUCESS="\033[34;1m"
MSGN_ERROR="\033[31;1m"
NEGRITO="\033[1m"
TEMP=temp.$$ # pid
# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #
# tem banco
[ ! -e "$DATABASE" ] && echo -e "${MSGN_ERROR}Arquivo não encontrado" && exit 1
[ ! -r "$DATABASE" ] && echo -e "${MSGN_ERROR}Não tem permissão de leitura" && exit 1
[ ! -w "$DATABASE" ] && echo -e "${MSGN_ERROR}Não tem permissão de escrita" && exit 1
# dialog
[ ! -x "$(which dialog)" ] && sudo apt install -y dialog 1> /dev/null 2>1
# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #
ListUser(){
	egrep -v "^#|^$" "$DATABASE" | tr : ' ' > $TEMP
	dialog --title "Lista de Usuarios" --textbox "$TEMP"  20 40
	rm -f "$TEMP"
}

ExistsUset(){
	grep -i -q "$1$SEP" "$DATABASE"
}

InsertUser(){
	local last_id="$(egrep -v "^#|^$" "$DATABASE" | tail -n 1 | cut -d $SEP -f 1)"
	local next_id=$(($last_id+1))

	local name=$(dialog --title "Cadastro de Usuario" --stdout --inputbox "Digite o seu nome" 0 0)
	[ ! "$name" ] && exit 1
	ExistsUset "$name" && {
		dialog --title "Error!!!" --msgbox "Usuario ja cadastrado" 6 40
		exit 1
	} 

	local email=$(dialog --title "Cadastro de Usuario" --stdout --inputbox "Digite o seu e-mail" 0 0)

	echo "$next_id$SEP$name$SEP$email" >> "$DATABASE"
	dialog --title "Sucesso!!!" --msgbox "Cadastrado!!" 6 40
	ListUser
}

DeleteUser(){
	# busca por id
	local user=$(egrep -v "^#|^$" "banco.txt" | sort -h | cut -d : -f 1,2 | sed 's/:/ "/;s/$/"/')
	local id_user=$(eval dialog --stdout --menu \"Escolha um usuario:\" 0 0 0 $user)

	# remove
	grep -i -v "^$id_user$SEP" "$DATABASE" > "$TEMP"
	mv "$TEMP" "$DATABASE"

	dialog --msgbox "Excluido!!" 6 40
	ListUser
}

OrderList(){
	sort "$DATABASE" > "$TEMP"
	mv "$TEMP" "$DATABASE"
}
# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #
while :
do
	action=$(dialog --title "Sistema Usuarios" \
					--stdout \
					--menu "Escolha uma das opções abaixo:" \
					0 0 0 \
					listar "Lista todos usuarios" \
					remover "Deleta um usuario" \
					inserir "Inserir um novo usuario")

	case $action in
		listar)  ListUser ;;
		inserir) InsertUser ;;
		remover) DeleteUser ;;
	esac				
done
# ------------------------------------------------------------------------ #
