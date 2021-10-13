VERSION=0.1

# Base dirs
MYEXPOS_PATH=$HOME/myexpos
XFS_INTERFACE_PATH=$MYEXPOS_PATH/xfs-interface
EXPL_PROGRAMS_DIR=$MYEXPOS_PATH/expl/expl_progs
SPL_PROGRAMS_DIR=$MYEXPOS_PATH/spl/spl_progs

# OS
OS_PATH_SPL=$SPL_PROGRAMS_DIR/os_startup.spl
OS_PATH_XSM=$SPL_PROGRAMS_DIR/os_startup.xsm

# Routines
HALT_ROUTINE_DIR=$SPL_PROGRAMS_DIR/haltprog.spl
HALT_ROUTINE_DIR_XSM=$SPL_PROGRAMS_DIR/haltprog.xsm
EXHANDLER_ROUTINE_DIR=$SPL_PROGRAMS_DIR/haltprog.spl
EXHANDLER_ROUTINE_DIR_XSM=$SPL_PROGRAMS_DIR/haltprog.xsm
TIMER_ROUTINE_DIR=$SPL_PROGRAMS_DIR/sample_timer.spl
TIMER_ROUTINE_DIR_XSM=$SPL_PROGRAMS_DIR/sample_timer.xsm
INT7_ROUTINE_DIR=$SPL_PROGRAMS_DIR/INT7.spl
INT7_ROUTINE_DIR_XSM=$SPL_PROGRAMS_DIR/INT7.xsm
# Menu de opciones:
#   Ejecutar la maquina xsm
#   Compilar y cargar OS
#   Compilar y cargar un proceso de usuario
#   Compilar y cargar rutinas
#   Programa de carga completo
#   Compilar programa SPL
#   Interfaz xfs
#   Salir


# Programa de carga completo:
#   compilar y cargar el OS
#   compilar y cargar las rutinas del OS (timer, except, etc)
#   compilar y cargar el programa de usuario definido por parametro
#   los valores para los directios y archivos seran definidos por variable de entorno

function run_xsm_machine()
{
    DEBUG_MODE=$1
    TIMER_AMOUNT=$2
    clear
    cd $MYEXPOS_PATH/xsm/
    if (($DEBUG_MODE == true)); then
        ./xsm --debug --timer $TIMER_AMOUNT
    else
        ./xsm --timer $TIMER_AMOUNT
    fi
}

function xsm_machine_menu()
{
    $XSM_DEBUG
    $XSM_TIMER
    clear
    echo ""
    read -p "Do you want to run in debug mode? (y/n): " XSM_DEBUG
    read -p "Please put the timer amount (0 for turning it off): " XSM_TIMER
    if [[XSM_DEBUG == 'y']]; then
        run_xsm_machine true $XSM_TIMER
    else
        run_xsm_machine true $XSM_TIMER
    fi
}

function compile_and_load_os()
{
    clear
    cd $MYEXPOS_PATH/spl/
    echo ""
    echo "Compiling ${OS_PATH_SPL}..."
    ./spl $OS_PATH_SPL
    echo "Compilation succesfull."
    echo ""
    echo "Loading OS in XSM machine..."
    cd $XFS_INTERFACE_PATH
    ./xfs-interface load --os $OS_PATH_XSM
    echo "OS loaded from: ${OS_PATH_XSM}."
}

function compile_spl_program()
{
    $FILENAME
    clear
    cd $MYEXPOS_PATH/spl
    echo ""
    read -p "Enter the filename of the program to be compiled: " FILENAME
    echo ""
    if [ -f "${SPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        ./spl ${SPL_PROGRAMS_DIR}/${FILENAME}
        if [[ $? -eq 0 ]]; then
            echo "File ${SPL_PROGRAMS_DIR}/${FILENAME} compiled succesfully."
        else
            echo "An error occured during the compiling process."
        fi
    else
        echo "The file: ${SPL_PROGRAMS_DIR}/${FILENAME} does not exists"
    fi
}

function load_expl_program()
{
    $FILENAME
    clear
    cd $XFS_INTERFACE_PATH
    echo ""
    read -p "Enter the filename of the program to be loaded: " FILENAME
    echo ""
    if [ -f "${EXPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        ./xfs-interface load --init ${EXPL_PROGRAMS_DIR}/${FILENAME}
        if [[ $? -eq 0 ]]; then
            echo "File ${EXPL_PROGRAMS_DIR}/${FILENAME} loaded succesfully."
        else
            echo "An error occured during the loading process."
        fi
    else
        echo "The file: ${EXPL_PROGRAMS_DIR}/${FILENAME} does not exists"
    fi
}


function compile_and_load_routine()
{
    ROUTINE=$1
    ROUTINE_NAME=$2
    CMD=$3
    cd $MYEXPOS_PATH/spl
    echo ""
    echo "Compiling ${ROUTINE_NAME}..."
    echo ""
    ./spl $ROUTINE
    if [[ $? -eq 0 ]]; then
        echo "Compilation sucessfull. Loading ${ROUTING_NAME}..."
        cd $XFS_INTERFACE_PATH
        ./xfs-interface $CMD
        echo "Loading process complete."
    else
        echo "Failed to compile ${ROUTINE_NAME}. Loading process aborted."
    fi
}


function compile_and_load_routines()
{
    clear
    echo ""
    compile_and_load_routine $HALT_ROUTINE_DIR "halt routine" "load --int=10 ${HALT_ROUTINE_DIR_XSM}"
    compile_and_load_routine $EXHANDLER_ROUTINE_DIR "exhandler routine" "load --exhandler ${EXHANDLER_ROUTINE_DIR_XSM}"
    compile_and_load_routine $TIMER_ROUTINE_DIR "timer routine" "load --int=timer ${TIMER_ROUTINE_DIR_XSM}"
    compile_and_load_routine $INT7_ROUTINE_DIR "int7 routine" "load --int=7 ${INT7_ROUTINE_DIR_XSM}"
    echo "All routines compiled and loaded."
    echo ""
}


function full_load()
{
    clear
    echo "------------------------ OS ------------------------"
    compile_and_load_os
    echo "------------------------ ROUTINES ------------------------"
    compile_and_load_routines
    echo "------------------------ USER PROGRAM ------------------------"
    load_expl_program
}

function main_menu()
{
    $OPTION
    clear
    echo "-----------------------------------------------------"
    echo "                eXpOS NITC main shell"
    echo "                      Version ${VERSION}"
    echo ""
    echo "-----------------------------------------------------"
    echo "1. Run XSM machine"
    echo "2. Compile and load OS"
    echo "3. Compile and load a program (expl)"
    echo "4. Compile and load routines"
    echo "5. Load everything."
    echo "6. Compile SPL program."
    echo "7. XFS interface."
    echo "Anything else will end the program."
    echo ""
    read -p "Choose your option: " OPTION
    if [[ OPTION -eq 1 ]]; then
        xsm_machine_menu
    elif [[ OPTION -eq 2 ]]; then
        compile_and_load_os
    elif [[ OPTION -eq 3 ]]; then
        load_expl_program
    elif [[ OPTION -eq 4 ]]; then
        compile_and_load_routines
    elif [[ OPTION -eq 5 ]]; then
        full_load
    elif [[ OPTION -eq 6 ]]; then
        compile_spl_program
    elif [[ OPTION -eq 7 ]]; then
        clear
        cd $XFS_INTERFACE_PATH
        ./xfs-interface
    fi
}

main_menu
