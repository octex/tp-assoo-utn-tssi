function show_config()
{
    clear
    echo ""
    echo "           ------------------"
    echo "          |     Internal     |"
    echo "           ------------------"
    echo "Project dir: ${MYEXPOS_PATH}"
    echo "XFS interface: ${XFS_INTERFACE_PATH}"
    echo "EXPL programs: ${EXPL_PROGRAMS_DIR}"
    echo "SPL programs: ${SPL_PROGRAMS_DIR}"
    echo ""
    echo "           ------------------"
    echo "          |        OS        |"
    echo "           ------------------"
    echo "SPL OS program: ${OS_PATH_SPL}"
    echo ""
    echo "           ------------------"
    echo "          |     Routines     |"
    echo "           ------------------"
    echo "Halt routine program: ${HALT_ROUTINE_DIR}"
    echo "Exhandler routine program: ${EXHANDLER_ROUTINE_DIR}"
    echo "Timer routine program: ${TIMER_ROUTINE_DIR}"
    echo "INT7 routine program: ${INT7_ROUTINE_DIR}"
    echo ""
    echo "For any modification check the config file variables: config.sh"
    echo ""
}


function run_xsm_machine()
{
    DEBUG_MODE=$1
    TIMER_AMOUNT=$2
    clear
    cd $MYEXPOS_PATH/xsm/
    if [[ $DEBUG_MODE == true ]]; then
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
    if [[ "$XSM_DEBUG" == "y" ]]; then
        XSM_DEBUG=''
        run_xsm_machine true $XSM_TIMER
    else
        XSM_DEBUG=''
        run_xsm_machine false $XSM_TIMER
    fi
}

function compile_and_load_os()
{
    cd $MYEXPOS_PATH/spl/
    echo ""
    echo "Compiling ${OS_PATH_SPL}..."
    ./spl $OS_PATH_SPL
    if [[ $? -eq 0 ]]; then
        echo "Compilation succesfull."
        echo ""
        echo "Loading OS in XSM machine..."
        cd $XFS_INTERFACE_PATH
        ./xfs-interface load --os $OS_PATH_XSM
        echo "OS loaded from: ${OS_PATH_XSM}"
        echo ""
    else
        echo "An error occured during the compilation process."
        echo "Loading process aborted."
        echo ""
    fi
}

function compile_spl_program()
{
    $FILENAME
    cd $MYEXPOS_PATH/spl
    clear
    echo ""
    ls ${SPL_PROGRAMS_DIR} -l | grep .spl
    echo ""
    read -p "Enter the filename of the program to be compiled: " FILENAME
    echo ""
    if [ -f "${SPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        ./spl ${SPL_PROGRAMS_DIR}/${FILENAME}
        if [[ $? -eq 0 ]]; then
            echo "File ${SPL_PROGRAMS_DIR}/${FILENAME} compiled succesfully."
        else
            echo "An error occured during the compilation process."
        fi
    else
        echo "The file: ${SPL_PROGRAMS_DIR}/${FILENAME} does not exists"
    fi
}

function compile_and_load_expl_program()
{
    $FILENAME
    cd $MYEXPOS_PATH/expl
    clear
    echo ""
    ls ${EXPL_PROGRAMS_DIR} -l | grep .expl
    echo ""
    read -p "Enter the filename of the program to be loaded: " FILENAME
    echo ""
    if [ -f "${EXPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        ./expl ${EXPL_PROGRAMS_DIR}/${FILENAME}
        if [[ $? -eq 0 ]]; then
            echo "File ${EXPL_PROGRAMS_DIR}/${FILENAME} compiled succesfully."
            echo "Loading file..."
            cd $XFS_INTERFACE_PATH
            ./xfs-interface "load --init ${EXPL_PROGRAMS_DIR}/${FILENAME}"
            echo "File ${EXPL_PROGRAMS_DIR}/${FILENAME} loaded."
        else
            echo "An error occured during the compilation process."
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
    echo ""
    compile_and_load_routine $HALT_ROUTINE_DIR "halt routine" "load --int=10 ${HALT_ROUTINE_DIR_XSM}"
    compile_and_load_routine $EXHANDLER_ROUTINE_DIR "exhandler routine" "load --exhandler ${EXHANDLER_ROUTINE_DIR_XSM}"
    compile_and_load_routine $TIMER_ROUTINE_DIR "timer routine" "load --int=timer ${TIMER_ROUTINE_DIR_XSM}"
    compile_and_load_routine $INT7_ROUTINE_DIR "int7 routine" "load --int=7 ${INT7_ROUTINE_DIR_XSM}"
    echo ""
}


function load_xfs_interface()
{
    clear
    cd $XFS_INTERFACE_PATH
    ./xfs-interface
}


function full_load()
{
    clear
    echo ""
    echo " This function will load:"
    echo "    - OS"
    echo "    - System routines"
    echo "    - Custom user program (expl)"
    echo ""
    read -p "Press any key to procced..."
    echo "------------------------ OS ------------------------"
    compile_and_load_os
    echo "------------------------ ROUTINES ------------------------"
    compile_and_load_routines
    echo "------------------------ USER PROGRAM ------------------------"
    compile_and_load_expl_program
}

function load_xsm_program_from_spl()
{
    $FILENAME
    cd $SPL_PROGRAMS_DIR
    clear
    echo ""
    ls -l | grep .xsm
    echo ""
    read -p "Enter the filename of the program to be loaded: " FILENAME
    echo ""
    if [ -f "${SPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        echo "Loading file..."
        cd $XFS_INTERFACE_PATH
        ./xfs-interface "load --init ${SPL_PROGRAMS_DIR}/${FILENAME}"
        echo "File ${SPL_PROGRAMS_DIR}/${FILENAME} loaded."
    else
        echo "The file: ${SPL_PROGRAMS_DIR}/${FILENAME} does not exists"
    fi
}


function load_xsm_program_from_expl()
{
    $FILENAME
    cd $EXPL_PROGRAMS_DIR
    clear
    ls -l | grep .xsm
    echo ""
    read -p "Enter the filename of the program to be loaded: " FILENAME
    echo ""
    if [ -f "${EXPL_PROGRAMS_DIR}/${FILENAME}" ]; then
        echo "Loading file..."
        cd $XFS_INTERFACE_PATH
        ./xfs-interface "load --init ${EXPL_PROGRAMS_DIR}/${FILENAME}"
        echo "File ${EXPL_PROGRAMS_DIR}/${FILENAME} loaded."
    else
        echo "The file: ${EXPL_PROGRAMS_DIR}/${FILENAME} does not exists"
    fi
}

function return_to_menu()
{
    $BACK_MENU
    read -p "Do you want to go back to main menu? (y/n): " BACKMENU
    if [[ "$BACKMENU" == "y" ]]; then
        main_menu
    else
        echo "Bye then."
    fi
}


function get_logo()
{
    echo "            ________________"
    echo "           |\     ####      \\"
    echo "           | \    #    #     \\"
    echo "           |  \    #    #     \\"
    echo "           |   \    #####      \\"
    echo "           |#   \_______________\\"
    echo "           |#  #|               |"
    echo "           | #  |               |"
    echo "           |# # |    ########   |"
    echo "           |  # |    #          |"
    echo "            \   |    ########   |"
    echo "             \  |           #   |"
    echo "              \ |    ########   |"
    echo "               \|_______________|"
}
