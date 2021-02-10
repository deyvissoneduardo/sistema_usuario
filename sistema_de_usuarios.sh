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
# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #
FormatDataUser(){
    local id="$(echo  $1 | cut -d $SEP -f 1)"
    local name="$(echo $1 | cut -d $SEP -f 2)"
    local email="$(echo $1 | cut -d $SEP -f 3)"

    echo -e "${NEGRITO}ID: $id"
    echo -e "${NEGRITO}name: $name"
    echo -e "${NEGRITO}E-Mail: $email" 
}

ListUser(){
    while read -r rows
    do
        #tem comentario
        [ "$(echo $rows | cut -c1)" = "#" ] && continue
        [ ! "$rows" ] && continue
        
        FormatDataUser "$rows"
    done < "$DATABASE"
	OrderList
}

ExistsUset(){
	grep -i -q "$1$SEP" "$DATABASE"
}

InsertUser(){
	# ja e cadastrado
	local name="$(echo $1 | cut -d $SEP -f 2)"

	if ExistsUset "$name"
	then
		echo -e "${MSGN_ERROR}Usuario ja cadastrado"
	else
		echo "$*" >> "$DATABASE"
		echo -e "${MSGN_SUCESS}Usuario Cadastrado com Sucesso!!!"
	fi
	OrderList
}

DeleteUser(){
	# ja existe
	ExistsUset "$1" || return 

	grep -i -v "$1$SEP" "$DATABASE" > "$TEMP"
	mv "$TEMP" "$DATABASE"

	echo -e "${MSGN_SUCESS}Usuario excluido"
	OrderList
}

OrderList(){
	sort "$DATABASE" > "$TEMP"
	mv "$TEMP" "$DATABASE"
}
# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #
# ------------------------------------------------------------------------ #
